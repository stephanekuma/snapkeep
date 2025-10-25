// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:snapkeep/src/core/constants/colors.dart';
import 'package:snapkeep/src/whatsapp/domain/entities/status.dart';
import 'package:snapkeep/src/whatsapp/presentation/bloc/status_bloc.dart';
import 'package:snapkeep/src/whatsapp/presentation/cubit/status_cubit.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StatusAction extends StatefulWidget {
  const StatusAction({
    super.key,
    required this.status,
    this.isStored = false,
    this.isFromSaved = false,
  });

  final Status status;
  final bool isStored;
  final bool isFromSaved;

  @override
  State<StatusAction> createState() => _StatusActionState();
}

class _StatusActionState extends State<StatusAction> {
  bool _isStored = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _isStored = widget.isStored;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStoredStatus();
    });

    // Vérifier périodiquement l'état
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _checkStoredStatus();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(StatusAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status.path != widget.status.path) {
      _checkStoredStatus();
    }
  }

  Future<void> _checkStoredStatus() async {
    final cubit = context.read<StatusCubit>();
    final isStored = await cubit.isStored(path: widget.status.path);
    if (mounted) {
      setState(() {
        _isStored = isStored;
      });
      print('StatusAction: _isStored = $isStored for ${widget.status.path}');
    }
  }

  IconData _getIcon() {
    if (widget.isFromSaved) {
      // Page Saved - toujours afficher poubelle
      return LucideIcons.trash2;
    } else if (_isStored) {
      // Pages Images/Videos - statut déjà sauvegardé - afficher check
      return LucideIcons.circleCheck;
    } else {
      // Pages Images/Videos - statut non sauvegardé - afficher téléchargement
      return LucideIcons.download;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StatusCubit>();

    print(
        'StatusAction build: widget.isStored = ${widget.isStored}, _isStored = $_isStored');

    return Stack(
      children: <Widget>[
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.r),
                bottomRight: Radius.circular(8.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  onPressed: () async {
                    // Si c'est un check (statut déjà sauvegardé et pas depuis Saved), ne rien faire
                    if (!widget.isFromSaved && _isStored) {
                      return; // Ne rien faire - comportement voulu
                    }

                    String message = '';

                    if (widget.isFromSaved) {
                      // Page Saved - supprimer le statut sauvegardé
                      cubit.destroy(path: widget.status.path);
                      context.read<StatusBloc>().add(FetchStoredStatuses());
                      message = !widget.status.isVideo
                          ? 'Image deleted'
                          : 'Video deleted';
                    } else {
                      // Pages Images/Videos - statut non sauvegardé - sauvegarder le statut
                      cubit.store(status: widget.status);
                      message = !widget.status.isVideo
                          ? 'Image saved'
                          : 'Video saved';
                    }

                    // Mettre à jour l'état immédiatement
                    setState(() {
                      if (widget.isFromSaved) {
                        // Page Saved - on supprime, donc _isStored devient false
                        _isStored = false;
                      } else {
                        // Pages Images/Videos - on sauvegarde, donc _isStored devient true
                        _isStored = true;
                      }
                    });

                    // Vérifier l'état réel après un court délai
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        _checkStoredStatus();
                      }
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor:
                              _isStored ? Colors.red : kPrimaryColor,
                          content: Text(
                            message,
                            style: TextStyle(
                              color: kWhiteColor,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    _getIcon(),
                    color: kWhiteColor,
                    size: 25.sp,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    cubit.share(status: widget.status);
                  },
                  icon: Icon(
                    LucideIcons.share2,
                    color: kWhiteColor,
                    size: 25.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
