import 'package:flutter/material.dart';
import 'package:school_erp/config/DynamicConstants.dart';
import 'package:school_erp/config/StaticConstants.dart';
import 'package:school_erp/domain/map/functions/Computational.dart';
import 'package:school_erp/domain/map/functions/RealTimeDb.dart';

class CustomFloatingButton extends StatefulWidget {
  final String selectedUid;
  const CustomFloatingButton({Key? key, required this.selectedUid})
      : super(key: key);

  @override
  State<CustomFloatingButton> createState() => _CustomFloatingButtonState();
}

class _CustomFloatingButtonState extends State<CustomFloatingButton> {
  late String selectedUid;

  Future<void> setValues() async {
    selectedUid = widget.selectedUid;
    totalDistanceTravelled = await getTotalDistanceTravelled();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setValues();
  }

  @override
  Widget build(BuildContext context) {
    setValues();
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Column(
        mainAxisAlignment: isSettingOpen
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.end,
        children: [
          if (isSettingOpen)
            Padding(
              padding: const EdgeInsets.only(top: 150),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 6.0,
                        )
                      ],
                    ),
                    child: Text('Zoom:${zoomMap.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 20.0)),
                  ),
                  Slider(
                    thumbColor: Colors.red,
                    label: "Zoom Map",
                    value: zoomMap,
                    onChanged: (value) {
                      zoomMap = value;
                      setState(() {});
                    },
                    min: 0.0,
                    max: 22.0,
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 6.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(50.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 6.0,
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Center(
                                child: Text('$speed',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: speedFont + 5)),
                              ),
                              Text('Km/h',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: speedFont)),
                            ],
                          ),
                        ),
                        FloatingActionButton(
                          mini: floatingMini,
                          onPressed: () {
                            focusMe = !focusMe;
                            focusDest = false;
                            setState(() {});
                          },
                          tooltip: 'Focus Me',
                          child: focusMe
                              ? const Icon(Icons.center_focus_strong)
                              : const ImageIcon(AssetImage(noFocusIcon)),
                        ),
                      ],
                    ),
                    if (selectedUid.isNotEmpty) const SizedBox(width: 8),
                    if (selectedUid.isNotEmpty)
                      FloatingActionButton(
                        mini: floatingMini,
                        onPressed: () {
                          focusDest = !focusDest;
                          focusMe = false;
                          setState(() {});
                        },
                        tooltip: 'Focus Dest',
                        child: focusDest
                            ? const Icon(Icons.person)
                            : const Icon(Icons.person_off_rounded),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isSettingOpen)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6.0,
                              horizontal: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 6.0,
                                )
                              ],
                            ),
                            child: Text(
                                '${totalDistanceTravelled.toStringAsFixed(2)} Km',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20.0)),
                          ),
                        if (isSettingOpen) const SizedBox(height: 8),
                        if (isSettingOpen)
                          FloatingActionButton(
                            mini: floatingMini,
                            onPressed: () {
                              setState(() {
                                iconVisible = !iconVisible;
                                MapFirebase().setTraceMe(iconVisible);
                              });
                            },
                            child: iconVisible
                                ? const Icon(Icons.remove_red_eye)
                                : const ImageIcon(AssetImage(inVisibleIcon)),
                          ),
                        if (isSettingOpen) const SizedBox(height: 8),
                        FloatingActionButton(
                          mini: floatingMini,
                          onPressed: () {
                            setState(() {
                              isSettingOpen = !isSettingOpen;
                            });
                          },
                          child: Icon(
                              isSettingOpen ? Icons.close : Icons.settings),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
