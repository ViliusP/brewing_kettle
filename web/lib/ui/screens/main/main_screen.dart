import 'package:brew_kettle_dashboard/ui/screens/main/tiles/current_temp.dart';
import 'package:brew_kettle_dashboard/ui/screens/main/tiles/grid_tile.dart';
import 'package:brew_kettle_dashboard/ui/screens/main/tiles/heater_control.dart';
import 'package:brew_kettle_dashboard/ui/screens/main/tiles/temp_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: true,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 960),
          child: ConstrainedBox(
            constraints: BoxConstraints.loose(Size.fromWidth(1600)),
            child: LayoutBuilder(builder: (context, constraints) {
              print(constraints);
              // 960
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: StaggeredGrid.count(
                  crossAxisCount: 5,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 4,
                  children: [
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 2,
                      child: DashboardTile(child: CurrentTempTile()),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 3,
                      mainAxisCellCount: 2,
                      child: DashboardTile(child: HeaterControlTile()),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 5,
                      mainAxisCellCount: 3,
                      child: DashboardTile(child: TempHistoryTile()),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
