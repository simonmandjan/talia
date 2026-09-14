import '../manage_imports.dart';

class MoovMoneyPaymentScreen extends StatefulWidget {
  final num? amount;

  MoovMoneyPaymentScreen({this.amount});

  @override
  MoovMoneyPaymentScreenState createState() => MoovMoneyPaymentScreenState();
}

class MoovMoneyPaymentScreenState extends State<MoovMoneyPaymentScreen> {
  static const int maxPollAttempts = 30; // ~2 minutes at 4s per attempt

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController(text: sharedPref.getString(CONTACT_NUMBER));

  bool submitting = false;
  bool waitingConfirmation = false;

  Timer? pollTimer;
  int pollAttempts = 0;

  @override
  void dispose() {
    pollTimer?.cancel();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void submit() async {
    if (!formKey.currentState!.validate()) return;

    submitting = true;
    setState(() {});

    final chargeAmount = widget.amount!.round();
    Map request = {
      'amount': chargeAmount,
      'currency': appStore.currencyName.toUpperCase(),
      'phone': phoneController.text.trim(),
    };

    await moovCreateCollection(request).then((value) {
      submitting = false;
      setState(() {});

      if (value.isFinalFailure) {
        toast(value.message ?? language.transactionFailed);
        return;
      }

      if (value.transactionId != null) {
        startPolling(value.transactionId!, chargeAmount);
      } else {
        toast(language.transactionFailed);
      }
    }).catchError((e) {
      submitting = false;
      setState(() {});
      toast(language.transactionFailed, print: true);
      log(e.toString());
    });
  }

  void startPolling(String transactionId, num chargeAmount) {
    waitingConfirmation = true;
    pollAttempts = 0;
    setState(() {});
    pollTimer = Timer.periodic(Duration(seconds: 4), (timer) => pollStatus(transactionId, chargeAmount));
  }

  void pollStatus(String transactionId, num chargeAmount) async {
    pollAttempts++;
    if (pollAttempts > maxPollAttempts) {
      pollTimer?.cancel();
      waitingConfirmation = false;
      setState(() {});
      toast('Your Moov Money payment is still processing. Please check your wallet balance in a moment before retrying.');
      return;
    }

    await moovGetCollectionStatus(transactionId).then((value) {
      if (value.isFinalSuccess) {
        pollTimer?.cancel();
        waitingConfirmation = false;
        setState(() {});
        toast(language.transactionSuccessful);
        creditWallet(chargeAmount);
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

  Future<void> creditWallet(num chargeAmount) async {
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
      Navigator.pop(context, true);
      Navigator.pop(context, true);
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Moov Money', style: boldTextStyle(color: appTextPrimaryColorWhite)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: phoneController,
                textFieldType: TextFieldType.PHONE,
                decoration: inputDecoration(context, label: language.phoneNumber),
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
          onTap: submitting || waitingConfirmation ? null : submit,
        ),
      ),
    );
  }
}
