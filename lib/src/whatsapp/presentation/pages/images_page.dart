import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:snapkeep/src/core/widgets/skeleton_loader.dart';
import 'package:snapkeep/src/whatsapp/presentation/bloc/status_bloc.dart';
import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';
import 'package:snapkeep/src/whatsapp/presentation/widgets/selectable_media_grid.dart';

@RoutePage()
class ImagesPage extends StatefulWidget {
  const ImagesPage({super.key});

  @override
  State<ImagesPage> createState() => _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage> {
  List<Status> _filteredStatuses = [];

  void _updateStatuses(List<Status> statuses) {
    setState(() {
      _filteredStatuses = statuses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<StatusBloc, StatusState>(
        listener: (context, state) {
          if (state is StatusLoadFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(state.message,
                    style: TextStyle(
                      fontSize: 14.sp,
                    )),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is LoadingStatus) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final availableHeight = constraints.maxHeight;

                // Calculer le nombre de colonnes basé sur la largeur
                int crossAxisCount = 3;
                if (screenWidth > 600) crossAxisCount = 4;
                if (screenWidth > 900) crossAxisCount = 5;
                if (screenWidth > 1200) crossAxisCount = 6;

                // Calculer la taille d'un élément (carré + spacing)
                final itemSize = (screenWidth / crossAxisCount) -
                    (8 * (crossAxisCount - 1)) / crossAxisCount;
                final spacing = 8.0;
                final totalItemHeight = itemSize + spacing;

                // Calculer le nombre de lignes qui rentrent dans l'espace disponible
                final rowsCount = (availableHeight / totalItemHeight).floor();
                // Ajouter 1-2 lignes supplémentaires pour donner l'impression de scroll
                final extraRows = 2;
                final itemCount =
                    ((rowsCount + extraRows) * crossAxisCount).clamp(6, 50);

                return SkeletonGrid(
                  itemCount: itemCount,
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.0,
                );
              },
            );
          }

          if (state is StatusLoadFailure) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/errors/error.png'),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            );
          }

          if (state is StatusLoaded) {
            // Update statuses
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateStatuses(state.statuses);
            });

            if (_filteredStatuses.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/images/errors/empty.png'),
                  Text(
                    'Aucune image trouvée',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              );
            } else {
              return SelectableMediaGrid(
                statuses: _filteredStatuses,
                isStored: false,
              );
            }
          }

          return Container();
        },
      ),
    );
  }
}
