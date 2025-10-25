import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:snapkeep/src/core/widgets/loader.dart';
import 'package:snapkeep/src/whatsapp/presentation/bloc/status_bloc.dart';
import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';
import 'package:snapkeep/src/whatsapp/presentation/widgets/selectable_media_grid.dart';

@RoutePage()
class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
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
                content: Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 14.sp,
                  ),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is LoadingStatus) {
            return const Loader();
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
                    'Aucune vidéo trouvée',
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
