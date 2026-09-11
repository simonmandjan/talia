import '../manage_imports.dart';

class SebPayPaymentScreen extends StatefulWidget {
  final num? amount;

  SebPayPaymentScreen({this.amount});

  @override
  SebPayPaymentScreenState createState() => SebPayPaymentScreenState();
}

class SebPayPaymentScreenState extends State<SebPayPaymentScreen> {
  static const int maxPollAttempts = 30; // ~2 minutes at 4s per attempt

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController(text: sharedPref.getString(CONTACT_NUMBER));
  TextEditingController otpController = TextEditingController();

  List<SebPayCountry> countries = [];
  List<SebPayOperator> operators = [];
  String? selectedCountryCode;
  String? selectedOperatorSlug;

  bool loadingCountries = true;
  bool loadingOperators = false;
  bool submitting = false;
  bool waitingConfirmation = false;

  Timer? pollTimer;
  int pollAttempts = 0;

  /// The rounded amount actually sent to SebPay for this attempt. Computed
  /// once in [submit] and reused by [creditWallet] so the customer is
  /// charged and the wallet is credited the exact same amount.
  int? chargeAmount;

  /// Whether a WebView was pushed on top of this screen for this attempt
  /// (Wave's provider_link flow). [creditWallet] needs to pop one extra
  /// screen when that happened.
  bool webViewWasPushed = false;

  @override
  void initState() {
    super.initState();
    fetchCountries();
  }

  @override
  void dispose() {
    pollTimer?.cancel();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  SebPayOperator? get selectedOperator {
    for (final o in operators) {
      if (o.slug == selectedOperatorSlug) return o;
    }
    return null;
  }

  bool get otpRequired => selectedOperator?.otpRequired == true;

  void fetchCountries() async {
    loadingCountries = true;
    setState(() {});
    await sebPayGetCountries().then((value) {
      loadingCountries = false;
      countries = value.data;
      setState(() {});
    }).catchError((e) {
      loadingCountries = false;
      setState(() {});
      toast(language.transactionFailed, print: true);
      log(e.toString());
    });
  }

  void onCountryChanged(String? code) async {
    selectedCountryCode = code;
    selectedOperatorSlug = null;
    operators = [];
    setState(() {});

    if (code == null) return;

    loadingOperators = true;
    setState(() {});
    await sebPayGetOperators(code).then((value) {
      loadingOperators = false;
      operators = value.data;
      setState(() {});
    }).catchError((e) {
      loadingOperators = false;
      setState(() {});
      toast(language.transactionFailed, print: true);
      log(e.toString());
    });
  }

  void submit() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedCountryCode == null || selectedOperatorSlug == null) {
      toast(language.thisFieldRequired);
      return;
    }
    if (otpRequired && otpController.text.trim().isEmpty) {
      toast(language.thisFieldRequired);
      return;
    }

    submitting = true;
    setState(() {});

    chargeAmount = widget.amount!.round();
    webViewWasPushed = false;

    Map request = {
      'amount': chargeAmount,
      'currency': appStore.currencyName.toUpperCase(),
      'phone': phoneController.text.trim(),
      'operator': selectedOperatorSlug,
      'country': selectedCountryCode,
    };
    if (otpRequired) request['otp_code'] = otpController.text.trim();

    await sebPayCreateCollection(request).then((value) {
      submitting = false;
      setState(() {});

      if (value.isFinalFailure) {
        toast(value.message ?? language.transactionFailed);
        return;
      }

      if (value.providerLink != null && value.providerLink!.isNotEmpty) {
        webViewWasPushed = true;
        launchScreen(
          context,
          WebViewScreen(title: 'Wave', mInitialUrl: value.providerLink),
        );
      }

      if (value.transactionId != null) {
        startPolling(value.transactionId!);
      }
    }).catchError((e) {
      submitting = false;
      setState(() {});
      toast(language.transactionFailed, print: true);
      log(e.toString());
    });
  }

  void startPolling(String transactionId) {
    waitingConfirmation = true;
    pollAttempts = 0;
    setState(() {});
    pollTimer = Timer.periodic(Duration(seconds: 4), (timer) => pollStatus(transactionId));
  }

  void pollStatus(String transactionId) async {
    pollAttempts++;
    if (pollAttempts > maxPollAttempts) {
      pollTimer?.cancel();
      waitingConfirmation = false;
      setState(() {});
      toast('Your SebPay payment is still processing. Please check your wallet balance in a moment before retrying.');
      return;
    }

    await sebPayGetCollection(transactionId).then((value) {
      if (value.isFinalSuccess) {
        pollTimer?.cancel();
        waitingConfirmation = false;
        setState(() {});
        toast(language.transactionSuccessful);
        creditWallet(transactionId);
      } else if (value.isFinalFailure) {
        pollTimer?.cancel();
        waitingConfirmation = false;
        setState(() {});
        toast(language.transactionFailed);
      }
      // otherwise still pending: keep polling
    }).catchError((e) {
      log(e.toString());
      // transient network error while polling: keep trying until maxPollAttempts
    });
  }

  Future<void> creditWallet(String transactionId) async {
    Map req = {
      "user_id": sharedPref.getInt(USER_ID),
      "type": "credit",
      "amount": chargeAmount,
      "transaction_type": "topup",
      "currency": appStore.currencyName.toUpperCase(),
    };
    appStore.setLoading(true);
    await saveWallet(req).then((value) {
      appStore.setLoading(false);
      // Pop one extra screen if a WebView (Wave provider_link) was pushed
      // on top of this screen, so the stack unwinds all the way back to
      // whichever screen originally launched this payment flow.
      if (webViewWasPushed) Navigator.pop(context, true);
      Navigator.pop(context, true);
      Navigator.pop(context, true);
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
      toast(
        'Your SebPay payment was successful, but updating your wallet balance failed. '
        'Please contact support and reference transaction $transactionId.',
        print: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SebPay', style: boldTextStyle(color: appTextPrimaryColorWhite)),
      ),
      body: loadingCountries
          ? loaderWidget()
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: inputDecoration(context, label: 'Country'),
                      items: countries.map((c) => DropdownMenuItem(value: c.code, child: Text(c.name.validate()))).toList(),
                      initialValue: selectedCountryCode,
                      onChanged: onCountryChanged,
                      validator: (value) => value == null ? language.thisFieldRequired : null,
                    ),
                    SizedBox(height: 16),
                    if (loadingOperators) loaderWidget(),
                    if (!loadingOperators)
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: inputDecoration(context, label: 'Mobile Money Operator'),
                        items: operators.map((o) => DropdownMenuItem(value: o.slug, child: Text(o.name.validate()))).toList(),
                        initialValue: selectedOperatorSlug,
                        onChanged: (value) {
                          selectedOperatorSlug = value;
                          otpController.clear();
                          setState(() {});
                        },
                        validator: (value) => value == null ? language.thisFieldRequired : null,
                      ),
                    SizedBox(height: 16),
                    AppTextField(
                      controller: phoneController,
                      textFieldType: TextFieldType.PHONE,
                      decoration: inputDecoration(context, label: language.phoneNumber),
                      errorThisFieldRequired: language.thisFieldRequired,
                    ),
                    if (otpRequired) SizedBox(height: 16),
                    if (otpRequired)
                      Text(
                        'Dial ${selectedOperator?.ussdCode ?? ''} on your phone to receive your confirmation code',
                        style: secondaryTextStyle(),
                      ),
                    if (otpRequired) SizedBox(height: 8),
                    if (otpRequired)
                      AppTextField(
                        controller: otpController,
                        textFieldType: TextFieldType.OTHER,
                        decoration: inputDecoration(context, label: 'OTP Code'),
                        errorThisFieldRequired: language.thisFieldRequired,
                      ),
                    if (waitingConfirmation) SizedBox(height: 16),
                    if (waitingConfirmation)
                      Text(
                        'Waiting for you to confirm this payment on your phone...',
                        style: secondaryTextStyle(),
                      ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: AppButtonWidget(
          text: language.pay,
          onTap: loadingCountries || submitting || waitingConfirmation ? null : submit,
        ),
      ),
    );
  }
}
