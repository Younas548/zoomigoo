import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoomigooo/screens/login.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zoomigoo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Onboarding(),
    );
  }
}

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final List<Map<String, String>> onBoardingData = [
    {
      "image": 'assets/images/intro1.png',
      "title": 'Anywhere you are',
      "description":
          'Sell houses easily with the help of Listenoryx and to make this line big I am writing more',
    },
    {
      "image": 'assets/images/intro2.png',
      "title": 'At anytime',
      "description":
          'Sell houses easily with the help of Listenoryx and to make this line big I am writing more.',
    },
    {
      "image": 'assets/images/intro3.png',
      "title": 'Book your car',
      "description":
          'Sell houses easily with the help of Listenoryx and to make this line big I am writing more.',
    },
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _continueMethod() {
    if (_currentPage < onBoardingData.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to login or home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PhoneLoginScreen(),
        ), // or any screen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () =>
                _pageController.jumpToPage(onBoardingData.length - 1),
            child: Text(
              'Skip',
              style: GoogleFonts.poppins(
                color: Colors.deepOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                physics: const ClampingScrollPhysics(),
                controller: _pageController,
                itemCount: onBoardingData.length,
                onPageChanged: _onChanged,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          onBoardingData[index]['image']!,
                          height: MediaQuery.of(context).size.height * 0.4,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          onBoardingData[index]['title']!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            onBoardingData[index]['description']!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50, left: 24, right: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onBoardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 12,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.deepOrange
                              : Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _continueMethod,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF08B783),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape:
                            CircleBorder(), // This makes the button perfectly circular
                      ),
                      child: Text(
                        _currentPage == onBoardingData.length - 1
                            ? 'GO'
                            : 'Next',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
