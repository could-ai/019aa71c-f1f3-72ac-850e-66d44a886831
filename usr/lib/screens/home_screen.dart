import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/story_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StoryService _storyService = StoryService();
  final ImagePicker _picker = ImagePicker();
  
  XFile? _image;
  String? _story;
  bool _isLoading = false;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
          _story = null;
          _error = null;
          _isLoading = true;
        });

        // Generate story
        try {
          final story = await _storyService.generateStory(pickedFile);
          if (mounted) {
            setState(() {
              _story = story;
              _isLoading = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _error = "Failed to generate story. Please try again.";
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        _error = "Error picking image: $e";
      });
    }
  }

  void _reset() {
    setState(() {
      _image = null;
      _story = null;
      _error = null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'SnapStory AI',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          if (_image != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _reset,
              tooltip: 'Start Over',
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_image == null) ...[
                    _buildHeroSection(),
                    const Spacer(),
                    _buildActionButtons(),
                    const Spacer(),
                  ] else ...[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildImageDisplay(),
                            const SizedBox(height: 24),
                            _buildStorySection(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        Icon(
          Icons.auto_awesome,
          size: 64,
          color: Colors.deepPurple.shade300,
        ),
        const SizedBox(height: 24),
        Text(
          "Instant Storyteller",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple.shade900,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Capture a moment or upload a photo.\nWe'll weave a vivid micro-story in seconds.",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionButton(
          icon: Icons.camera_alt_rounded,
          label: "Take Photo",
          color: Colors.deepPurple,
          onPressed: () => _pickImage(ImageSource.camera),
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          icon: Icons.photo_library_rounded,
          label: "Upload from Gallery",
          color: Colors.deepPurple.shade100,
          textColor: Colors.deepPurple.shade900,
          onPressed: () => _pickImage(ImageSource.gallery),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(icon),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildImageDisplay() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: kIsWeb
          ? Image.network(
              _image!.path,
              fit: BoxFit.cover,
            )
          : Image.file(
              File(_image!.path),
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _buildStorySection() {
    if (_isLoading) {
      return Column(
        children: [
          const SizedBox(height: 32),
          const CircularProgressIndicator(
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 16),
          Text(
            "Analyzing scene details...",
            style: GoogleFonts.inter(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Text(
          _error!,
          style: GoogleFonts.inter(color: Colors.red.shade700),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "THE STORY",
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.deepPurple.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: 32,
                color: Colors.deepPurple.shade200,
              ),
              const SizedBox(height: 8),
              Text(
                _story ?? "",
                textAlign: TextAlign.center,
                style: GoogleFonts.merriweather(
                  fontSize: 18,
                  height: 1.6,
                  color: Colors.grey.shade800,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _reset,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.deepPurple.shade200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              "Capture Another Moment",
              style: GoogleFonts.inter(
                color: Colors.deepPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
