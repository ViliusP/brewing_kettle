import 'package:brew_kettle_dashboard/ui/screens/main/tiles/current_temp.dart';
import 'package:brew_kettle_dashboard/ui/screens/main/tiles/grid_tile.dart';
import 'package:brew_kettle_dashboard/ui/screens/main/tiles/target_temp.dart';
import 'package:brew_kettle_dashboard/ui/screens/main/tiles/temp_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: true,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints.loose(Size.fromWidth(1600)),
          child: LayoutBuilder(builder: (context, constraints) {
            // 900
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: StaggeredGrid.count(
                crossAxisCount: 8,
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
                    child: DashboardTile(child: TargetTempTile()),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 3,
                    mainAxisCellCount: 1,
                    child: Tile(title: "Button 1"),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 3,
                    mainAxisCellCount: 1,
                    child: Tile(title: "Button 2"),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 5,
                    mainAxisCellCount: 3,
                    child: DashboardTile(child: TempHistoryTile()),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 3,
                    mainAxisCellCount: 1,
                    child: Tile(title: "Button 3"),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 3,
                    mainAxisCellCount: 1,
                    child: Tile(title: "Button 4"),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 3,
                    mainAxisCellCount: 1,
                    child: Tile(title: "Button 5"),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 3,
                    child: SizedBox(),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 4,
                    mainAxisCellCount: 3,
                    child: Tile(title: "keypad"),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 3,
                    child: SizedBox(),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
