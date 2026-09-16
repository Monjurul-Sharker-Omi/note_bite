You are an expert Flutter developer and UI/UX designer. I want to build a feature-rich, highly interactive study app for students with a "Retro Japanese Minimalist" aesthetic. 

Here are the strict technical specifications and design guidelines I need you to follow to create the clean architecture and UI code for this app.

---

## 1. Technical Stack & Architecture
- State Management: Flutter BLoC (with clean event/state separation).
- Local Database: Hive or Isar (for storing a nested folder tree structure: Course/Subject -> Chapter -> Local PDF/Doc Paths -> Flashcards).
- Local File Handling: path_provider (save picked files to app documents directory, save only path strings in Hive).
- AI Integration: Gemini Free API (specifically utilizing the Gemini Files API to upload documents and stream back structured JSON for flashcards).
- Offline First: All files and flashcards must be saved, read, and editable locally offline.

---

## 2. Design System & Aesthetic (Retro Japanese Minimalist)
- Background Color: An elegant cream/off-white (#FDFBF7 or #F5F2EB) reminiscent of vintage Japanese manga paper or aged stationary.
- Typography: Use the Google Font 'Andika' or 'Cutive' for headings and titles to evoke a typewriter/retro-editorial vibe.
- Accent Palette: Muted, earthy retro tones. 
  - Indigo/Navy Blue (#2E3D52) for heavy text and crisp borders.
  - Wasabi Green (#8F9E7B) or Crimson Red (#C86558) for status badges, tags, and small accents.
- Card Elements: Give cards a tactile feel using solid 2D drop shadows (Neubrutalism style but softer)—sharp borders (1px width, Indigo color) and a fixed shadow offset (e.g., `BoxShadow(color: Color(0xFF2E3D52), offset: Offset(4, 4))`) instead of blurry blurs.
- UI Element Style: Minimalist layouts with generous whitespace, subtle Japanese geometric grid accents, or small katakana subtitles (e.g., "ノート" for Notes) near section headers to seal the aesthetic.

---

## 3. High-Fidelity UI Features & Animations
The app must feel incredibly lucrative and premium through buttery-smooth animations:

A. Folder & Navigation Layout:
- A modular layout showing Course folders. Tapping a folder uses an elegant cascading animation where chapter subfolders slide up into place with a staggered delay interval.

B. Interactive 3D Flashcard Deck:
- A stack of flashcards rendered inside a custom BLoC state view.
- Gestures: Implement a physics-based card swiper using GestureDetector and Transform. Swiping left or right should apply a dynamically calculated Y-axis and Z-axis rotation giving the card simulated physical weight.
- Card Flip: Tapping a flashcard triggers a beautiful 180-degree flip animation using an AnimatedBuilder. The front text swaps seamlessly with the back text at exactly 90 degrees of rotation.
- Inline Editing: The texts on these flashcards must be editable inline via a clean text field that saves changes directly back to Hive through the BLoC.

C. Loading/Processing States:
- While the Gemini API processes the document, show a beautiful "Retro Document Scanner" animation: a minimalist card placeholder where a subtle colored laser line glides up and down across a typewriter-pattern grid.

---

## 4. The Implementation Plan
Please break down the codebase creation step-by-step:
1. Provide the complete pubspec.yaml configurations (including Google Fonts, Hive, and BLoC dependencies).
2. Generate the Hive Data Models supporting the Course -> Chapter -> Card nested hierarchy.
3. Write the BLoC implementation (`FlashcardBloc`, `FlashcardEvent`, `FlashcardState`) managing file uploads, AI generation states, and local card text edits.
4. Provide the Flutter UI code for the 3D-flipping/swiping Flashcard view styled completely in the specified Retro Cream/Japanese Minimalist aesthetic.

Let's begin with Step 1 and 2.