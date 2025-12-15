import 'package:flutter/material.dart';
import 'package:zimax/src/components/svgicon.dart';

class RepostButton extends StatefulWidget {
  final String count;

  const RepostButton({super.key, required this.count});

  @override
  State<RepostButton> createState() => _RepostButtonState();
}

class _RepostButtonState extends State<RepostButton>
    with SingleTickerProviderStateMixin {
  bool isReposted = false;
  bool isLoading = false;

  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _rotation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRepost() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    // 🔄 animate rotation
    _controller.forward(from: 0);

    // 🔔 show loading snackbar
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(days: 1),
        content: _loadingSnack(),
      ),
    );

    // ⏳ simulate backend call
    await Future.delayed(const Duration(seconds: 2));

    messenger.hideCurrentSnackBar();

    setState(() {
      isReposted = true;
      isLoading = false;
    });
  }

  Widget _loadingSnack() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: const [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 12),
          Text(
            "re-posting...",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleRepost,
      child: Row(
        children: [
          RotationTransition(
            turns: _rotation,
            child: SvgIcon(
              'assets/activicon/repost.svg',
              size: 18,
              color: isReposted
                  ? Colors.green
                  : const Color.fromARGB(255, 8, 10, 12),
            ),
          ),
          if (widget.count.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              widget.count,
              style: TextStyle(
                fontSize: 13,
                color: isReposted
                    ? Colors.green
                    : const Color.fromARGB(255, 7, 7, 8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
