import 'package:flutter/material.dart';
import 'dart:ui';

class LiquidSliderTab extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<String> titles;
  final bool isDarkMode;

  const LiquidSliderTab({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.titles,
    required this.isDarkMode,
  });

  @override
  State<LiquidSliderTab> createState() => _LiquidSliderTabState();
}

class _LiquidSliderTabState extends State<LiquidSliderTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _trackWidth = 0;
  double _thumbPosition = 0;
  bool _isDragging = false;
  double _velocity = 0;
  Offset _lastPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
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
    setState(() {});
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging || _trackWidth == 0) return;

    final deltaX = details.globalPosition.dx - _lastPosition.dx;
    _lastPosition = details.globalPosition;
    _velocity = deltaX / 16;

    final itemWidth = _trackWidth / widget.titles.length;
    _thumbPosition = (_thumbPosition + deltaX).clamp(itemWidth / 2, _trackWidth - itemWidth / 2);

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
    setState(() {
      final itemWidth = _trackWidth / widget.titles.length;
      _thumbPosition = itemWidth * index + itemWidth / 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDarkMode = widget.isDarkMode;

    return LayoutBuilder(
      builder: (context, constraints) {
        _trackWidth = constraints.maxWidth;
        final itemWidth = _trackWidth / widget.titles.length;
        
        if (!_isDragging) {
          _thumbPosition = itemWidth * widget.currentIndex + itemWidth / 2;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 阴影层
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode 
                          ? Colors.black.withValues(alpha: 0.45)
                          : Colors.black.withValues(alpha: 0.1),
                      blurRadius: 28,
                      spreadRadius: 0,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: isDarkMode 
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.white.withValues(alpha: 0.5),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
              ),
            ),
            // 内容层
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 16,
                  sigmaY: 16,
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.32),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isDarkMode 
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.18),
                      width: 1,
                    ),
                  ),
                  child: GestureDetector(
                    onPanStart: _handleDragStart,
                    onPanUpdate: _handleDragUpdate,
                    onPanEnd: _handleDragEnd,
                    behavior: HitTestBehavior.translucent,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Liquid thumb
                        AnimatedPositioned(
                          left: _thumbPosition - itemWidth / 2,
                          top: 3,
                          bottom: 3,
                          width: itemWidth,
                          duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          child: _LiquidThumb(
                            isDragging: _isDragging,
                            velocity: _velocity,
                            primaryColor: primaryColor,
                            isDarkMode: isDarkMode,
                          ),
                        ),
                        
                        // Tab items
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
                                  borderRadius: BorderRadius.circular(20),
                                  splashColor: isDarkMode 
                                      ? Colors.white.withValues(alpha: 0.15)
                                      : Colors.black.withValues(alpha: 0.08),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    alignment: Alignment.center,
                                    child: Text(
                                      widget.titles[index],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected 
                                            ? primaryColor
                                            : isDarkMode 
                                                ? Colors.white.withValues(alpha: 0.75)
                                                : Colors.black.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LiquidThumb extends StatelessWidget {
  final bool isDragging;
  final double velocity;
  final Color primaryColor;
  final bool isDarkMode;

  const _LiquidThumb({
    required this.isDragging,
    required this.velocity,
    required this.primaryColor,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final scaleX = 1 - (velocity * 0.5).clamp(-0.12, 0.12);
    final scaleY = 1 - (velocity * 0.15).clamp(-0.08, 0.08);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      transform: Matrix4.diagonal3Values(
        scaleX * (isDragging ? 1.06 : 1),
        scaleY * (isDragging ? 0.96 : 1),
        1,
      ),
      child: Stack(
        children: [
          // Soft ambient glow that blends with navigation bar
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: isDragging ? 0.35 : 0.15),
                  blurRadius: isDragging ? 28 : 20,
                  spreadRadius: isDragging ? 3 : 1,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          
          // Glass container - more integrated with navigation bar
          ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: isDragging ? 20 : 14,
                sigmaY: isDragging ? 20 : 14,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color: isDarkMode 
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.5, 1.0],
                    colors: [
                      isDarkMode 
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.15),
                      isDarkMode 
                          ? Colors.transparent
                          : Colors.white.withValues(alpha: 0.08),
                      isDarkMode 
                          ? Colors.black.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.03),
                    ],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.4, 1.0],
                      colors: [
                        primaryColor.withValues(alpha: isDragging ? 0.25 : 0.15),
                        primaryColor.withValues(alpha: isDragging ? 0.12 : 0.06),
                        primaryColor.withValues(alpha: 0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(19),
                  ),
                ),
              ),
            ),
          ),
          
          // Inner highlight for glass
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              border: Border.all(
                color: isDarkMode 
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.18),
                width: 0.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.2],
                colors: [
                  isDarkMode 
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // Subtle inner shadow
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDragging ? 0.12 : 0.06),
                  blurRadius: isDragging ? 6 : 3,
                  offset: const Offset(0, 2),
                  blurStyle: BlurStyle.inner,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}