import 'dart:math';
import 'package:image_picker/image_picker.dart';

class StoryService {
  // Mock stories to simulate AI response
  final List<String> _mockStories = [
    "Sunlight dances across the vibrant scene. Nature awakens with a gentle whisper of the wind. A sense of peace fills the air.",
    "The chaotic energy bustles with life here. Movement blurs into a symphony of action and purpose. Energy pulses through every corner of the frame.",
    "A solitary subject stands out against the background. The composition highlights a moment of quiet reflection. Hope lingers in the stillness.",
    "Laughter seems to echo from this frozen moment. Joy is captured in its purest form, unburdened by time. It reminds us to cherish the little things.",
    "Shadows play tricks on the eye in this shot. Mystery shrouds the details, inviting the viewer to look closer. A secret waits to be discovered.",
    "Colors explode in a dazzling display of vibrancy. The visual feast overwhelms the senses with delight. Creativity knows no bounds here."
  ];

  Future<String> generateStory(XFile image) async {
    // Simulate network processing delay (1.5 - 2.5 seconds)
    final random = Random();
    final delay = 1500 + random.nextInt(1000);
    await Future.delayed(Duration(milliseconds: delay));

    // Return a random story from the list
    return _mockStories[random.nextInt(_mockStories.length)];
  }
}
