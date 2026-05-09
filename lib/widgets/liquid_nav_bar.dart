import 'package:flutter/material.dart';
import 'dart:ui';

enum NavBarMode {
  iconsOnly,    // 仅显示图标
  iconsWithText, // 图标+文字
}

class LiquidNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<String> titles;
  final List<IconData> icons;
  final List<IconData> activeIcons;
  final NavBarMode mode;
  final bool isDarkMode;
  final double height;
  final double borderRadius;

  const LiquidNavBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.titles,
    required this.icons,
    required this.activeIcons,
    this.mode = NavBarMode.iconsOnly,
    required this.isDarkMode,
    this.height = 60,
    this.borderRadius = 24,
  });

  @override
  State<LiquidNavBar> createState() => _LiquidNavBarState();
}

class _LiquidNavBarState extends State<LiquidNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;
  double _trackWidth = 0;
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
    if (!_isDragging || _trackWidth == 0) return;

    final deltaX = details.globalPosition.dx - _lastPosition.dx;
    _lastPosition = details.globalPosition;
    _velocity = deltaX / 16;

    final itemWidth = _trackWidth / widget.titles.length;
    _thumbPosition = (_thumbPosition + deltaX).clamp(itemWidth / 2, _trackWidth - itemWidth / 2);
    _targetThumbPosition = _thumbPosition;

    final targetIndex = ((_thumbPosition - itemWidth / 2) / itemWidth).round().clamp(0, widget.titles.length - 1);
    
    if (targetIndex != widget.currentIndex) {
      widget.onIndexChanged(targetIndex);
    }

    setState(() {});
  }

  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;
    _velocity = 0;
    
    final itemWidth = _trackWidth / widget.titles.length;
    final targetIndex = ((_thumbPosition - itemWidth / 2) / itemWidth).round().clamp(0, widget.titles.length - 1);
    
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDarkMode = widget.isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = MediaQuery.of(context).padding;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: padding.bottom + 8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: _getNavBarDecoration(isDarkMode),
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _trackWidth = constraints.maxWidth;
          final itemWidth = _trackWidth / widget.titles.length;
          
          if (!_isDragging && _trackWidth > 0) {
            _targetThumbPosition = itemWidth * widget.currentIndex + itemWidth / 2;
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
                AnimatedPositioned(
                  left: _thumbPosition - itemWidth / 2,
                  top: 4,
                  width: itemWidth,
                  height: widget.height - 12,
                  duration: _isDragging ? Duration.zero : const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  child: _LiquidThumb(
                    isDragging: _isDragging,
                    velocity: _velocity,
                    primaryColor: primaryColor,
                    isDarkMode: isDarkMode,
                    mode: widget.mode,
                    height: widget.height - 12,
                  ),
                ),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(widget.titles.length, (index) {
                    final isSelected = widget.currentIndex == index;
                    return Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _animateToIndex(index);
                            widget.onIndexChanged(index);
                          },
                          borderRadius: BorderRadius.circular(16),
                          splashColor: isDarkMode 
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.08),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            padding: widget.mode == NavBarMode.iconsOnly
                                ? const EdgeInsets.symmetric(vertical: 10)
                                : const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            alignment: Alignment.center,
                            child: widget.mode == NavBarMode.iconsOnly
                                ? AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    transitionBuilder: (child, animation) {
                                      return ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      );
                                    },
                                    child: Icon(
                                      key: ValueKey(isSelected),
                                      isSelected 
                                          ? widget.activeIcons[index]
                                          : widget.icons[index],
                                      size: 24,
                                      color: isSelected 
                                          ? primaryColor
                                          : isDarkMode 
                                              ? Colors.white.withValues(alpha: 0.7)
                                              : Colors.black.withValues(alpha: 0.6),
                                    ),
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 250),
                                        transitionBuilder: (child, animation) {
                                          return ScaleTransition(
                                            scale: animation,
                                            child: child,
                                          );
                                        },
                                        child: Icon(
                                          key: ValueKey(isSelected),
                                          isSelected 
                                              ? widget.activeIcons[index]
                                              : widget.icons[index],
                                          size: 20,
                                          color: isSelected 
                                              ? primaryColor
                                              : isDarkMode 
                                                  ? Colors.white.withValues(alpha: 0.7)
                                                  : Colors.black.withValues(alpha: 0.6),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 250),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected 
                                              ? primaryColor
                                              : isDarkMode 
                                                  ? Colors.white.withValues(alpha: 0.75)
                                                  : Colors.black.withValues(alpha: 0.7),
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
    );
  }

  BoxDecoration _getNavBarDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode 
          ? Colors.black.withValues(alpha: 0.5)
          : Colors.white.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: isDarkMode 
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDarkMode 
              ? Colors.black.withValues(alpha: 0.4)
              : Colors.black.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: isDarkMode 
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.white.withValues(alpha: 0.8),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
    );
  }
}

class _LiquidThumb extends StatelessWidget {
  final bool isDragging;
  final double velocity;
  final Color primaryColor;
  final bool isDarkMode;
  final NavBarMode mode;
  final double height;

  const _LiquidThumb({
    required this.isDragging,
    required this.velocity,
    required this.primaryColor,
    required this.isDarkMode,
    required this.mode,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final scaleX = 1 - (velocity * 0.5).clamp(-0.12, 0.12);
    final scaleY = 1 - (velocity * 0.15).clamp(-0.08, 0.08);
    final borderRadius = height / 2;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      height: height,
      transform: Matrix4.diagonal3Values(
        scaleX * (isDragging ? 1.06 : 1),
        scaleY * (isDragging ? 0.96 : 1),
        1,
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.35),
                  blurRadius: isDragging ? 16 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          
          Container(
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.white.withValues(alpha: 0.92)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 2,
                  sigmaY: 2,
                ),
                child: Container(
                  color: primaryColor.withValues(alpha: 0.06),
                ),
              ),
            ),
          ),
          
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
                colors: [
                  Colors.white.withValues(alpha: 0.7),
                  Colors.white.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDragging ? 0.12 : 0.06),
                  blurRadius: isDragging ? 5 : 3,
                  offset: const Offset(0, 2),
                  blurStyle: BlurStyle.inner,
                ),
              ],
            ),
          ),
          
          if (isDragging)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}