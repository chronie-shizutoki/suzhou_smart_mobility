import 'package:flutter/material.dart';
import 'dart:ui';

class LiquidSliderTab extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<String> titles;
  final bool isDarkMode;
  final double height;

  const LiquidSliderTab({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.titles,
    required this.isDarkMode,
    this.height = 52,
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
    if (!_isDragging || _trackWidth == 0 || widget.titles.isEmpty) return;

    final deltaX = details.globalPosition.dx - _lastPosition.dx;
    _lastPosition = details.globalPosition;
    _velocity = deltaX / 16;

    final itemWidth = _trackWidth / widget.titles.length;
    _thumbPosition = (_thumbPosition + deltaX).clamp(itemWidth / 2, _trackWidth - itemWidth / 2);

    final targetIndex = ((_thumbPosition - itemWidth / 2) / itemWidth).round().clamp(0, widget.titles.length - 1);
    final currentIndex = widget.currentIndex ?? 0;
    
    if (targetIndex != currentIndex) {
      widget.onIndexChanged(targetIndex);
    }

    setState(() {});
  }

  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;
    _velocity = 0;
    
    if (_trackWidth > 0 && widget.titles.isNotEmpty) {
      final itemWidth = _trackWidth / widget.titles.length;
      final targetIndex = ((_thumbPosition - itemWidth / 2) / itemWidth).round().clamp(0, widget.titles.length - 1);
      _animateToIndex(targetIndex);
    }
    setState(() {});
  }

  void _animateToIndex(int index) {
    setState(() {
      if (_trackWidth > 0 && widget.titles.isNotEmpty) {
        final itemWidth = _trackWidth / widget.titles.length;
        _thumbPosition = itemWidth * index + itemWidth / 2;
      }
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
        
        if (_trackWidth <= 0 || widget.titles.isEmpty) {
          return Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(widget.height / 2),
            ),
          );
        }
        
        final itemWidth = _trackWidth / widget.titles.length;
        final currentIndex = widget.currentIndex ?? 0;
        
        if (!_isDragging) {
          _thumbPosition = itemWidth * currentIndex + itemWidth / 2;
        }

        return Container(
          height: widget.height,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDarkMode 
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(widget.height / 2),
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
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: isDarkMode 
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.white.withValues(alpha: 0.8),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: GestureDetector(
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
                  duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: _LiquidThumb(
                    isDragging: _isDragging,
                    velocity: _velocity,
                    primaryColor: primaryColor,
                    isDarkMode: isDarkMode,
                    height: widget.height - 12,
                  ),
                ),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(widget.titles.length, (index) {
                    final isSelected = currentIndex == index;
                    return Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _animateToIndex(index);
                            widget.onIndexChanged(index);
                          },
                          borderRadius: BorderRadius.circular(widget.height / 2),
                          splashColor: isDarkMode 
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.08),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            alignment: Alignment.center,
                            child: Text(
                              widget.titles[index],
                              style: TextStyle(
                                fontSize: 15,
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
  final double height;

  const _LiquidThumb({
    required this.isDragging,
    required this.velocity,
    required this.primaryColor,
    required this.isDarkMode,
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
                  blurRadius: isDragging ? 14 : 8,
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
                    blurRadius: 10,
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