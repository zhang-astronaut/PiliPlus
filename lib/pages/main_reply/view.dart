import 'package:PiliPlus/common/skeleton/video_reply.dart';
import 'package:PiliPlus/common/sliver_single_child_delegate.dart';
import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/ui_kit/miuix_page.dart';
import 'package:PiliPlus/common/widgets/sliver/sliver_floating_header.dart';
import 'package:PiliPlus/common/widgets/view_safe_area.dart';
import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart'
    show ReplyInfo;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/pages/common/fab_mixin.dart';
import 'package:PiliPlus/pages/main_reply/controller.dart';
import 'package:PiliPlus/pages/video/reply/widgets/reply_item_grpc.dart';
import 'package:PiliPlus/pages/video/reply_reply/view.dart';
import 'package:PiliPlus/utils/extension/widget_ext.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:PiliPlus/utils/num_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter_miuix/miuix.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class MainReplyPage extends StatefulWidget {
  const MainReplyPage({super.key});

  @override
  State<MainReplyPage> createState() => _MainReplyPageState();

  static void toMainReplyPage({
    required int oid,
    required int replyType,
  }) {
    Get.toNamed(
      '/mainReply',
      arguments: {
        'oid': oid,
        'replyType': replyType,
      },
    );
  }
}

class _MainReplyPageState extends State<MainReplyPage>
    with SingleTickerProviderStateMixin, BaseFabMixin, FabMixin {
  final _controller = Get.put(
    MainReplyController(),
    tag: Utils.generateRandomString(8),
  );

  late EdgeInsets padding;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    padding = MediaQuery.viewPaddingOf(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return PiliMiuixPage(
      title: '查看评论',
      floatingActionButton: SlideTransition(
        position: fabAnimation,
        child: MiuixFloatingActionButton(
          onPressed: () {
            try {
              feedBack();
              _controller.onReply(
                null,
                oid: _controller.oid,
                replyType: _controller.replyType,
              );
            } catch (_) {}
          },
          child: const MiuixIcon(icon: Icons.reply),
        ),
      ),
      content: (context, contentPadding) => fabAnimWrapper(
        child: refreshIndicator(
          onRefresh: _controller.onRefresh,
          child: Padding(
            padding: contentPadding,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                buildReplyHeader(colorScheme),
                Obx(
                  () => _buildBody(colorScheme, _controller.loadingState.value),
                ),
              ],
            ),
          ),
        ).constraintWidth(),
      ),
    );
  }

  Widget _buildBody(
    ColorScheme colorScheme,
    LoadingState<List<ReplyInfo>?> loadingState,
  ) {
    return switch (loadingState) {
      Loading() => const SliverPrototypeExtentList(
        prototypeItem: VideoReplySkeleton(),
        delegate: SliverSingleChildDelegate(
          count: 10,
          child: VideoReplySkeleton(),
        ),
      ),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverList.builder(
                itemCount: response.length + 1,
                itemBuilder: (context, index) {
                  if (index == response.length) {
                    _controller.onLoadMore();
                    return Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: padding.bottom),
                      height: 125,
                      child: Text(
                        _controller.isEnd ? '没有更多了' : '加载中...',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.outline,
                        ),
                      ),
                    );
                  } else {
                    return ReplyItemGrpc(
                      replyItem: response[index],
                      replyLevel: 1,
                      replyReply: (replyItem, id) =>
                          replyReply(context, replyItem, id, colorScheme),
                      onReply: _controller.onReply,
                      onDelete: (item, subIndex) =>
                          _controller.onRemove(index, item, subIndex),
                      upMid: _controller.upMid,
                      onCheckReply: _controller.onCheckReply,
                      onToggleTop: (item) => _controller.onToggleTop(
                        item,
                        index,
                        _controller.oid,
                        _controller.replyType,
                      ),
                    );
                  }
                },
              )
            : HttpError(
                errMsg: '还没有评论',
                onReload: _controller.onReload,
              ),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }

  Widget buildReplyHeader(ColorScheme colorScheme) {
    final secondary = colorScheme.secondary;
    return SliverFloatingHeaderWidget(
      backgroundColor: colorScheme.surface,
      child: Padding(
        padding: const .fromLTRB(12, 2.5, 6, 2.5),
        child: Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Obx(
              () {
                final count = _controller.count.value;
                return Text(
                  '${count == -1 ? 0 : NumUtils.numFormat(count)}条回复',
                );
              },
            ),
            TextButton.icon(
              style: Style.buttonStyle,
              onPressed: _controller.queryBySort,
              icon: Icon(Icons.sort, size: 16, color: secondary),
              label: Obx(
                () => Text(
                  _controller.sortType.value.descShort,
                  style: TextStyle(fontSize: 13, color: secondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void replyReply(
    BuildContext context,
    ReplyInfo replyItem,
    int? id,
    ColorScheme colorScheme,
  ) {
    EasyThrottle.throttle('replyReply', const Duration(milliseconds: 500), () {
      int oid = replyItem.oid.toInt();
      int rpid = replyItem.id.toInt();
      Get.to(
        PiliMiuixPage(
          title: '评论详情',
          content: (context, contentPadding) => Padding(
            padding: contentPadding,
            child: ViewSafeArea(
            child: VideoReplyReplyPanel(
              enableSlide: false,
              id: id,
              oid: oid,
              rpid: rpid,
              isVideoDetail: false,
              replyType: _controller.replyType,
              firstFloor: replyItem,
              upMid: _controller.upMid,
            ),
          ).constraintWidth(),
          ),
        ),
        routeName: 'dynamicDetail-Copy',
      );
    });
  }
}
