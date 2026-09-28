import '../manage_imports.dart';
import '../model/search_location_model.dart' hide Text;

class HomeDestinationCard extends StatefulWidget {
  final String? sourceTitle;
  final VoidCallback onSourceChanged;

  HomeDestinationCard({required this.sourceTitle, required this.onSourceChanged});

  @override
  HomeDestinationCardState createState() => HomeDestinationCardState();
}

class HomeDestinationCardState extends State<HomeDestinationCard> {
  TextEditingController sourceController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  FocusNode destinationFocus = FocusNode();
  List<Suggestion> listAddress = [];
  List<RiderModel> recentDestinations = [];
  bool _sourceManuallyChanged = false;

  @override
  void initState() {
    super.initState();
    sourceController.text = widget.sourceTitle ?? '';
    loadRecentDestinations();
  }

  @override
  void didUpdateWidget(HomeDestinationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The parent rebuilds this widget with a new sourceTitle once geolocation
    // resolves asynchronously (including re-fetches triggered by the device's
    // location-services toggle). Once the rider has manually picked a source
    // via the bottom sheet, that choice must never be silently overwritten by
    // a later auto-detected value.
    if (_sourceManuallyChanged) return;
    if (widget.sourceTitle != oldWidget.sourceTitle) {
      sourceController.text = widget.sourceTitle ?? '';
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void loadRecentDestinations() async {
    try {
      RiderListModel value = await getRiderRequestList(page: 1, status: COMPLETED, riderId: sharedPref.getInt(USER_ID));
      List<RiderModel> rides = value.data ?? [];
      List<RiderModel> distinct = [];
      Set<String> seenAddresses = {};
      for (RiderModel ride in rides) {
        String? address = ride.endAddress;
        if (address == null || address.isEmpty) continue;
        if (ride.endLatitude == null || ride.endLongitude == null) continue;
        if (double.tryParse(ride.endLatitude!) == null || double.tryParse(ride.endLongitude!) == null) continue;
        if (seenAddresses.contains(address)) continue;
        seenAddresses.add(address);
        distinct.add(ride);
        if (distinct.length >= 3) break;
      }
      recentDestinations = distinct;
      setState(() {});
    } catch (e) {
      // Recent destinations are optional polish, not load-bearing: on any
      // failure the section simply stays empty, no error surfaced to the rider.
      recentDestinations = [];
    }
  }

  // Mirrors TripTypeLocationComponent's own address-search pattern exactly
  // (lib/components/TripTypeLocationComponent.dart): type >= 3 characters,
  // get live suggestions from the same autocomplete endpoint.
  void searchAddress(String val) {
    if (val.length < 3) {
      listAddress.clear();
      setState(() {});
      return;
    }
    Map req = {
      "search_text": val,
      "language": appStore.selectedLanguage.validate(value: defaultLanguageCode),
    };
    searchAddressRequest(req).then((value) {
      listAddress = value.suggestions;
      setState(() {});
    }).catchError((error) {
      log(error);
    });
  }

  void selectSuggestion(Suggestion suggestion) async {
    await searchAddressRequestPlaceId(suggestion.placePrediction.placeId).then((value) {
      destinationController.text = value.formattedAddress;
      polylineDestination = LatLng(value.location.latitude, value.location.longitude);
      listAddress.clear();
      setState(() {});
    }).catchError((error) {
      log(error);
    });
  }

  Future<void> pickDestinationFromMap() async {
    var selectedPlace = await launchScreen(context, GoogleMapScreen(isDestination: true), pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
    if (selectedPlace == null) return;
    polylineDestination = selectedPlace['position'];
    destinationController.text = selectedPlace['formatted_address'];
    setState(() {});
  }

  void selectRecentDestination(RiderModel ride) {
    polylineDestination = LatLng(double.parse(ride.endLatitude!), double.parse(ride.endLongitude!));
    destinationController.text = ride.endAddress!;
    setState(() {});
  }

  // The auto-detected position stays the default source - this only opens a
  // typed-address form (never jumps straight to the map) for the rare case
  // the rider wants to change it, e.g. ordering for someone else.
  Future<void> changeSourceLocation() async {
    final result = await showModalBottomSheet<Map>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(defaultRadius), topRight: Radius.circular(defaultRadius))),
      builder: (context) => SourceAddressSearchSheet(initialText: sourceController.text),
    );
    if (result == null) return;
    _sourceManuallyChanged = true;
    sourceController.text = result['formatted_address'];
    sourceLocation = result['position'];
    polylineSource = result['position'];
    sourceLocationTitle = result['formatted_address'];
    widget.onSourceChanged();
    setState(() {});
  }

  void continueToEstimate() {
    launchScreen(
      context,
      Newestimateridelistwidget(
        trip_type: tripTypeRegular,
        is_taxi_service: true,
        tripDetail: {'trip_type': getTripTypeValue(tripTypeRegular)},
        sourceLatLog: polylineSource,
        destinationLatLog: polylineDestination,
        sourceTitle: sourceController.text,
        destinationTitle: destinationController.text,
      ),
      pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canContinue = sourceController.text.isNotEmpty && destinationController.text.isNotEmpty;
    bool showRecent = recentDestinations.isNotEmpty && listAddress.isEmpty && destinationController.text.isEmpty;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(defaultRadius),
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 2, spreadRadius: 1)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(defaultRadius)),
            child: Row(
              children: [
                Icon(Icons.near_me, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sourceController.text.isNotEmpty ? sourceController.text : language.fetchingAddress,
                    style: boldTextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                inkWellWidget(
                  onTap: changeSourceLocation,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                    child: Icon(Icons.chevron_right, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          AppTextField(
            controller: destinationController,
            focus: destinationFocus,
            textFieldType: TextFieldType.NAME,
            onChanged: searchAddress,
            decoration: inputDecoration(
              context,
              label: language.destinationLocation,
              prefixIcon: Icon(Icons.location_on_outlined),
              suffixIcon: IconButton(
                onPressed: pickDestinationFromMap,
                icon: Icon(Icons.map_outlined),
              ),
            ),
          ),
          if (listAddress.isNotEmpty) SizedBox(height: 8),
          ...listAddress.map((suggestion) {
            return inkWellWidget(
              onTap: () => selectSuggestion(suggestion),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 18, color: primaryColor),
                    SizedBox(width: 8),
                    Expanded(child: Text(suggestion.placePrediction.text.text, style: primaryTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            );
          }),
          if (showRecent) SizedBox(height: 8),
          if (showRecent)
            ...recentDestinations.map((ride) {
              return inkWellWidget(
                onTap: () => selectRecentDestination(ride),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.history, size: 18, color: Colors.grey),
                      SizedBox(width: 8),
                      Expanded(child: Text(ride.endAddress ?? '', style: secondaryTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              );
            }),
          SizedBox(height: 12),
          AppButtonWidget(
            width: MediaQuery.of(context).size.width,
            enabled: canContinue,
            color: primaryColor,
            onTap: continueToEstimate,
            text: language.continueD,
            textStyle: boldTextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// Bottom sheet for changing the default (auto-detected) source position by
// typing an address, with live suggestions - the map picker is offered only
// as a secondary fallback at the bottom, never the first/only option.
class SourceAddressSearchSheet extends StatefulWidget {
  final String initialText;

  SourceAddressSearchSheet({required this.initialText});

  @override
  State<SourceAddressSearchSheet> createState() => SourceAddressSearchSheetState();
}

class SourceAddressSearchSheetState extends State<SourceAddressSearchSheet> {
  late TextEditingController controller;
  List<Suggestion> listAddress = [];

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialText);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void searchAddress(String val) {
    if (val.length < 3) {
      listAddress.clear();
      setState(() {});
      return;
    }
    Map req = {
      "search_text": val,
      "language": appStore.selectedLanguage.validate(value: defaultLanguageCode),
    };
    searchAddressRequest(req).then((value) {
      listAddress = value.suggestions;
      setState(() {});
    }).catchError((error) {
      log(error);
    });
  }

  void selectSuggestion(Suggestion suggestion) async {
    await searchAddressRequestPlaceId(suggestion.placePrediction.placeId).then((value) {
      Navigator.pop(context, {
        'position': LatLng(value.location.latitude, value.location.longitude),
        'formatted_address': value.formattedAddress,
      });
    }).catchError((error) {
      log(error);
    });
  }

  Future<void> pickFromMap() async {
    var selectedPlace = await launchScreen(context, GoogleMapScreen(isDestination: true), pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
    if (selectedPlace == null) return;
    Navigator.pop(context, selectedPlace);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(bottom: 16),
                height: 5,
                width: 70,
                decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(defaultRadius)),
              ),
            ),
            Text(language.currentLocation, style: boldTextStyle()),
            SizedBox(height: 8),
            AppTextField(
              controller: controller,
              textFieldType: TextFieldType.NAME,
              autoFocus: true,
              onChanged: searchAddress,
              decoration: inputDecoration(context, label: language.destinationLocation, prefixIcon: Icon(Icons.location_on_outlined)),
            ),
            SizedBox(height: 8),
            ...listAddress.map((suggestion) {
              return inkWellWidget(
                onTap: () => selectSuggestion(suggestion),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 18, color: primaryColor),
                      SizedBox(width: 8),
                      Expanded(child: Text(suggestion.placePrediction.text.text, style: primaryTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: 8),
            inkWellWidget(
              onTap: pickFromMap,
              child: Row(
                children: [
                  Icon(Icons.map_outlined, size: 18, color: primaryColor),
                  SizedBox(width: 8),
                  Text(language.chooseOnMap, style: primaryTextStyle(color: primaryColor)),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
