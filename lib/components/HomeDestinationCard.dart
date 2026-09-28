import '../manage_imports.dart';

class HomeDestinationCard extends StatefulWidget {
  final String? sourceTitle;
  final VoidCallback onSourceChanged;

  HomeDestinationCard({required this.sourceTitle, required this.onSourceChanged});

  @override
  HomeDestinationCardState createState() => HomeDestinationCardState();
}

class HomeDestinationCardState extends State<HomeDestinationCard> {
  TextEditingController destinationController = TextEditingController();
  List<RiderModel> recentDestinations = [];

  @override
  void initState() {
    super.initState();
    loadRecentDestinations();
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

  Future<void> changeSourceLocation() async {
    var selectedPlace = await launchScreen(context, GoogleMapScreen(isDestination: true), pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
    if (selectedPlace == null) return;
    sourceLocation = selectedPlace['position'];
    polylineSource = selectedPlace['position'];
    sourceLocationTitle = selectedPlace['formatted_address'];
    widget.onSourceChanged();
  }

  Future<void> pickDestination() async {
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

  void continueToEstimate() {
    launchScreen(
      context,
      Newestimateridelistwidget(
        trip_type: tripTypeRegular,
        is_taxi_service: true,
        tripDetail: {'trip_type': getTripTypeValue(tripTypeRegular)},
        sourceLatLog: polylineSource,
        destinationLatLog: polylineDestination,
        sourceTitle: widget.sourceTitle ?? '',
        destinationTitle: destinationController.text,
      ),
      pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canContinue = (widget.sourceTitle ?? '').isNotEmpty && destinationController.text.isNotEmpty;

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
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(defaultRadius)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    (widget.sourceTitle ?? '').isNotEmpty ? widget.sourceTitle! : language.fetchingAddress,
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
            textFieldType: TextFieldType.NAME,
            readOnly: true,
            enabled: true,
            onTap: pickDestination,
            decoration: inputDecoration(context, label: language.destinationLocation, prefixIcon: Icon(Icons.location_on_outlined)),
          ),
          if (recentDestinations.isNotEmpty) SizedBox(height: 8),
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
