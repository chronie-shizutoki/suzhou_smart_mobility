import 'package:flutter/material.dart';
import 'dart:ui';

class LiquidSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onValueChanged;
  final double min;
  final double max;
  final Color? activeColor;
  final Color? trackColor;
  final double? trackHeight;
  final double? thumbWidth;
  final double? thumbHeight;

  const LiquidSlider({
    super.key,
    required this.value,
    required this.onValueChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.activeColor,
    this.trackColor,
    this.trackHeight = 6,
    this.thumbWidth = 40,
    this.thumbHeight = 24,
  })  : assert(min <= max),
        assert(value >= min && value <= max);

  @override
  State<LiquidSlider> createState() => _LiquidSliderState();
}

class _LiquidSliderState extends State<LiquidSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  double _trackWidth = 0;
  double _currentValue = 0;
  bool _isDragging = false;
  double _velocity = 0;
  Offset _lastPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void didUpdateWidget(covariant LiquidSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _currentValue = widget.value;
      _animateToValue(widget.value);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateToValue(double targetValue) {
    _animationController.forward(from: 0);
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

    final range = widget.max - widget.min;
    final deltaValue = (deltaX / _trackWidth) * range;
    
    setState(() {
      _currentValue = (widget.value + deltaValue)
          .clamp(widget.min, widget.max);
      widget.onValueChanged(_currentValue);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;
    _velocity = 0;
    
    setState(() {});
  }

  void _handleTap(TapUpDetails details) {
    if (_trackWidth == 0) return;
    
    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    
    final range = widget.max - widget.min;
    final targetValue = (localPosition.dx / _trackWidth) * range + widget.min;
    
    _animateToValue(targetValue.clamp(widget.min, widget.max));
    widget.onValueChanged(targetValue.clamp(widget.min, widget.max));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    final accentColor = widget.activeColor ?? (isDarkMode 
        ? const Color(0xFF0091FF) 
        : const Color(0xFF0088FF));
    final trackColor = widget.trackColor ?? (isDarkMode 
        ? const Color(0xFF787880).withValues(alpha: 0.36) 
        : const Color(0xFF787878).withValues(alpha: 0.2));

    return LayoutBuilder(
      builder: (context, constraints) {
        _trackWidth = constraints.maxWidth;
        
        final progress = (_currentValue - widget.min) / (widget.max - widget.min);
        final thumbPosition = progress * _trackWidth;
        
        return Stack(
          children: [
            // Track background
            GestureDetector(
              onTapUp: _handleTap,
              child: Container(
                height: widget.trackHeight,
                decoration: BoxDecoration(
                  color: trackColor,
                  borderRadius: BorderRadius.circular(widget.trackHeight! / 2),
                ),
              ),
            ),
            
            // Active track
            ClipRRect(
              borderRadius: BorderRadius.circular(widget.trackHeight! / 2),
              child: Container(
                height: widget.trackHeight,
                width: thumbPosition,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(widget.trackHeight! / 2),
                ),
              ),
            ),
            
            // Thumb with liquid glass effect
            Positioned(
              left: thumbPosition - widget.thumbWidth! / 2,
              top: (widget.trackHeight! - widget.thumbHeight!) / 2,
              child: GestureDetector(
                onPanStart: _handleDragStart,
                onPanUpdate: _handleDragUpdate,
                onPanEnd: _handleDragEnd,
                child: _LiquidThumb(
                  width: widget.thumbWidth!,
                  height: widget.thumbHeight!,
                  isDragging: _isDragging,
                  velocity: _velocity,
                  accentColor: accentColor,
                  isDarkMode: isDarkMode,
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
  final double width;
  final double height;
  final bool isDragging;
  final double velocity;
  final Color accentColor;
  final bool isDarkMode;

  const _LiquidThumb({
    required this.width,
    required this.height,
    required this.isDragging,
    required this.velocity,
    required this.accentColor,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final scaleX = 1 - (velocity * 0.75).clamp(-0.2, 0.2);
    final scaleY = 1 - (velocity * 0.25).clamp(-0.2, 0.2);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: width * (isDragging ? 1.5 : 1),
      height: height,
      transform: Matrix4.diagonal3Values(
        scaleX * (isDragging ? 1.1 : 1),
        scaleY * (isDragging ? 0.9 : 1),
        1,
      ),
      child: Stack(
        children: [
          // Outer shadow
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          
          // Glass container
          Container(
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.white.withValues(alpha: 0.9 - (isDragging ? 0.3 : 0))
                  : Colors.white.withValues(alpha: 0.95 - (isDragging ? 0.3 : 0)),
              borderRadius: BorderRadius.circular(height / 2),
              border: Border.all(
                color: isDarkMode 
                    ? Colors.white.withValues(alpha: 0.3)
                    : accentColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(height / 2),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: isDragging ? 4 : 8,
                  sigmaY: isDragging ? 4 : 8,
                ),
                child: Container(
                  color: accentColor.withValues(alpha: 0.1),
                  child: Stack(
                    children: [
                      // Inner highlight
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: height / 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: isDragging ? 0.8 : 0.5),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(height / 2),
                            ),
                          ),
                        ),
                      ),
                      
                      // Color overlay
                      Center(
                        child: Container(
                          width: width * 0.6,
                          height: height * 0.6,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: isDragging ? 0.8 : 0.4),
                            borderRadius: BorderRadius.circular(height * 0.3),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Lens effect glow
                      if (isDragging)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(height / 2),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Inner shadow
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDragging ? 0.2 : 0.05),
                  blurRadius: isDragging ? 8 : 4,
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