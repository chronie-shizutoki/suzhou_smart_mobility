import 'dart:ui';
import 'package:flutter/material.dart';
import 'liquid_nav_bar.dart';

/// Top navigation bar used on large screens (tablet / desktop).
///
/// Unlike the floating bottom bar on phones, this one sits at the very top
/// of the screen and shows both an icon and a text label for every entry,
/// which reads better when there is plenty of horizontal space.
///
/// It reuses the same "liquid glass" treatment as [LiquidNavBar]: a frosted,
/// blurred surface with a soft, sliding highlight thumb behind the selected
/// item. The thumb can be dragged with the finger and snaps to the nearest
/// tab, just like the bottom bar.
class TopNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<String> titles;
  final List<IconData> icons;
  final List<IconData>? activeIcons;
  final bool isDarkMode;

  const TopNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.titles,
    required this.icons,
    this.activeIcons,
    required this.isDarkMode,
  });

  @override
  State<TopNavigationBar> createState() => _TopNavigationBarState();
}

class _TopNavigationBarState extends State<TopNavigationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;
  double _trackWidth = 0;
  double _itemWidth = 0;
  double _thumbPosition = 0;
  double _targetThumbPosition = 0;
  bool _isDragging = false;
  double _velocity = 0;
  Offset _lastPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _positionAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _positionAnimation.addListener(() {
      setState(() {
        _thumbPosition = _positionAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
    _lastPosition = details.globalPosition;
    _velocity = 0;
    _animationController.stop();
    setState(() {});
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging || _trackWidth == 0 || _itemWidth == 0) return;

    final deltaX = details.globalPosition.dx - _lastPosition.dx;
    _lastPosition = details.globalPosition;
    _velocity = deltaX / 16;

    _thumbPosition = (_thumbPosition + deltaX)
        .clamp(_itemWidth / 2, _trackWidth - _itemWidth / 2);
    _targetThumbPosition = _thumbPosition;

    final targetIndex = ((_thumbPosition - _itemWidth / 2) / _itemWidth)
        .round()
        .clamp(0, widget.titles.length - 1);

    if (targetIndex != widget.currentIndex) {
      widget.onIndexChanged(targetIndex);
    }

    setState(() {});
  }

  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;
    _velocity = 0;

    final targetIndex = ((_thumbPosition - _itemWidth / 2) / _itemWidth)
        .round()
        .clamp(0, widget.titles.length - 1);

    _animateToIndex(targetIndex);
    setState(() {});
  }

  void _animateToIndex(int index) {
    final itemWidth = _trackWidth / widget.titles.length;
    _targetThumbPosition = itemWidth * index + itemWidth / 2;

    _positionAnimation = Tween<double>(
      begin: _thumbPosition,
      end: _targetThumbPosition,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward(from: 0);
  }

  void _selectIndex(int index) {
    _animateToIndex(index);
    widget.onIndexChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = widget.isDarkMode;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.1),
            blurRadius: 28,
            spreadRadius: 0,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: isDark ? 0.06 : 0.5),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.32),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                _trackWidth = constraints.maxWidth;
                _itemWidth = _trackWidth / widget.titles.length;

                if (!_isDragging && _trackWidth > 0) {
                  _targetThumbPosition =
                      _itemWidth * widget.currentIndex + _itemWidth / 2;
                  if (_thumbPosition == 0) {
                    _thumbPosition = _targetThumbPosition;
                  }
                }

                return GestureDetector(
                  onPanStart: _handleDragStart,
                  onPanUpdate: _handleDragUpdate,
                  onPanEnd: _handleDragEnd,
                  behavior: HitTestBehavior.translucent,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Sliding liquid highlight thumb behind the active item.
                      AnimatedPositioned(
                        left: _thumbPosition - _itemWidth / 2,
                        top: 3,
                        bottom: 3,
                        width: _itemWidth,
                        duration:
                            _isDragging ? Duration.zero : const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        child: LiquidThumb(
                          isDragging: _isDragging,
                          velocity: _velocity,
                          primaryColor: primary,
                          isDarkMode: isDark,
                          mode: NavBarMode.iconsOnly,
                        ),
                      ),
                      // Navigation items (icon + text).
                      Row(
                        children: List.generate(widget.titles.length, (index) {
                          final isSelected = index == widget.currentIndex;
                          final iconData = isSelected
                              ? (widget.activeIcons != null
                                  ? widget.activeIcons![index]
                                  : widget.icons[index])
                              : widget.icons[index];
                          return Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _selectIndex(index),
                                borderRadius: BorderRadius.circular(16),
                                splashColor: isDark
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : Colors.black.withValues(alpha: 0.08),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        iconData,
                                        size: 22,
                                        color: isSelected
                                            ? primary
                                            : isDark
                                                ? Colors.white
                                                    .withValues(alpha: 0.75)
                                                : Colors.black
                                                    .withValues(alpha: 0.6),
                                      ),
                                      const SizedBox(width: 10),
                                      AnimatedDefaultTextStyle(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? primary
                                              : isDark
                                                  ? Colors.white.withValues(
                                                      alpha: 0.75)
                                                  : Colors.black.withValues(
                                                      alpha: 0.7),
                                        ),
                                        child: Text(widget.titles[index]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
