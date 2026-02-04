//------------------------------------------------------------------------------
// LEARNING OBJECTIVE:
// This tutorial will teach you how to use DOM manipulation in JavaScript
// to create a dynamic color palette generator and a simple drawing canvas.
// We will focus on:
// 1. Selecting and manipulating HTML elements.
// 2. Event listeners to make our application interactive.
// 3. Generating dynamic content (color swatches).
// 4. Using basic canvas drawing functions.
//------------------------------------------------------------------------------

// --- 1. HTML Structure (Assumed) ---
// For this script to work, you'll need an HTML file with the following elements:
// <div id="paletteContainer"></div>
// <canvas id="drawingCanvas" width="500" height="300"></canvas>
// <button id="generateButton">Generate New Palette</button>
//
// Explanation:
// - paletteContainer: This is where our generated color swatches will be placed.
// - drawingCanvas: This is the HTML5 canvas element where we will "paint".
// - generateButton: This button will trigger the generation of a new color palette.

// --- 2. JavaScript Code ---

// Get references to the important HTML elements.
// 'const' is used because these references won't change.
const paletteContainer = document.getElementById('paletteContainer');
const canvas = document.getElementById('drawingCanvas');
const generateButton = document.getElementById('generateButton');

// Get the 2D rendering context for the canvas.
// This object provides the drawing methods.
const ctx = canvas.getContext('2d');

// Variable to store the currently selected color.
let selectedColor = '#000000'; // Default to black.

// --- Event Listener for Button Click ---
// We add an event listener to the generate button.
// When the button is clicked, the provided function will execute.
generateButton.addEventListener('click', generateColorPalette);

// --- Function to Generate a Random Hex Color ---
// A hex color is a 6-digit hexadecimal number preceded by '#'.
// Example: #FF0000 (red), #00FF00 (green), #0000FF (blue).
function getRandomHexColor() {
  // Generates a random number between 0 and 16777215 (which is 255*255*255).
  // This represents all possible RGB combinations.
  const randomColorValue = Math.floor(Math.random() * 16777215);
  // Converts the decimal number to a hexadecimal string.
  const hexString = randomColorValue.toString(16);
  // Pads the string with leading zeros if it's shorter than 6 characters,
  // ensuring we always get a valid 6-digit hex code.
  return '#' + hexString.padStart(6, '0');
}

// --- Function to Create a Single Color Swatch Element ---
function createColorSwatch(color) {
  // Create a new 'div' element to represent the color swatch.
  const swatch = document.createElement('div');
  // Add a CSS class for styling. You'd style this class in your CSS file.
  swatch.classList.add('color-swatch');
  // Set the background color of the swatch to the provided color.
  swatch.style.backgroundColor = color;
  // Store the color value in a data attribute for later retrieval.
  // 'data-*' attributes are a standard way to embed custom data in HTML.
  swatch.dataset.color = color;

  // Add an event listener to this swatch.
  // When clicked, it will set 'selectedColor' to this swatch's color.
  swatch.addEventListener('click', () => {
    selectedColor = color;
    console.log('Selected color:', selectedColor); // Log to console for debugging.
    // Optional: Add visual feedback to show which color is selected.
    // For simplicity, we're just logging it here.
  });

  // Return the created swatch element.
  return swatch;
}

// --- Function to Generate and Display the Color Palette ---
function generateColorPalette() {
  // Clear any existing swatches from the palette container.
  // This prevents duplicates when generating a new palette.
  paletteContainer.innerHTML = '';

  // Define how many colors we want in our palette.
  const numberOfColors = 5;

  // Loop to create and add the specified number of color swatches.
  for (let i = 0; i < numberOfColors; i++) {
    // Generate a new random color.
    const newColor = getRandomHexColor();
    // Create a color swatch element for this color.
    const swatchElement = createColorSwatch(newColor);
    // Append the newly created swatch to the palette container in the HTML.
    paletteContainer.appendChild(swatchElement);
  }
}

// --- Canvas Drawing Functionality ---

// Variable to track if the mouse button is currently down.
let isDrawing = false;

// Event listener for when the mouse button is pressed down on the canvas.
canvas.addEventListener('mousedown', (event) => {
  // Set 'isDrawing' to true to indicate we are starting to draw.
  isDrawing = true;
  // Call 'draw' once to capture the starting point of the stroke.
  draw(event);
});

// Event listener for when the mouse pointer moves over the canvas.
canvas.addEventListener('mousemove', (event) => {
  // Only draw if the mouse button is down ('isDrawing' is true).
  if (!isDrawing) return;
  // Call the 'draw' function to draw a line segment.
  draw(event);
});

// Event listener for when the mouse button is released anywhere on the page.
// We listen on 'document' to catch clicks even if the mouse leaves the canvas.
document.addEventListener('mouseup', () => {
  // Set 'isDrawing' to false to stop drawing.
  isDrawing = false;
});

// --- The Core Drawing Function ---
function draw(event) {
  // Prevent default browser behavior (e.g., text selection).
  event.preventDefault();

  // Get the current mouse position relative to the canvas.
  // 'event.clientX' and 'event.clientY' give the mouse position relative to the viewport.
  // 'canvas.getBoundingClientRect()' gives the position and dimensions of the canvas.
  const rect = canvas.getBoundingClientRect();
  const mouseX = event.clientX - rect.left;
  const mouseY = event.clientY - rect.top;

  // Configure the drawing context.
  ctx.lineWidth = 5; // Set the thickness of the line.
  ctx.lineCap = 'round'; // Make the ends of lines rounded.
  ctx.strokeStyle = selectedColor; // Set the drawing color to the currently selected color.

  // Begin a new path. This starts a new drawing stroke.
  ctx.beginPath();
  // Move the drawing pen to the current mouse position without drawing.
  // This sets the starting point for the line segment.
  ctx.moveTo(mouseX, mouseY);
  // Draw a line from the previous point (or start of path) to the current mouse position.
  // 'event.movementX' and 'event.movementY' are the differences in mouse position
  // since the last 'mousemove' event. This allows us to draw continuous lines.
  // Note: For simplicity in this tutorial, we are directly using mouseX/mouseY
  // and relying on the `mousedown` and `mouseup` events to manage `isDrawing`.
  // A more robust approach for continuous drawing would involve storing the
  // last known position and drawing from that to the current position.
  // For this simplified example, we'll draw a small segment at each mousemove.
  // A better way to draw continuous lines on mousemove is shown below.

  // Let's improve the drawing to be continuous. We need to store the last position.
  // We'll add a global variable for this.
  if (!draw.lastX) { // Initialize if not set
      draw.lastX = mouseX;
      draw.lastY = mouseY;
  }

  // Draw a line from the last recorded position to the current position.
  ctx.lineTo(mouseX, mouseY);
  // Render the path (the line) on the canvas.
  ctx.stroke();

  // Update the last recorded position for the next 'mousemove' event.
  draw.lastX = mouseX;
  draw.lastY = mouseY;
}


// --- Initialization ---
// Call generateColorPalette once when the script loads to display an initial palette.
generateColorPalette();

// --- Example Usage & Explanation ---
// 1. Open your HTML file in a browser.
// 2. You should see a canvas and a "Generate New Palette" button.
// 3. Click "Generate New Palette" to get a new set of colors.
// 4. Click on any color swatch to select it.
// 5. Click and drag your mouse on the canvas to "paint" with the selected color.
// 6. Click the button again to generate a new palette and continue painting.
//
// This code demonstrates how JavaScript can interact with HTML elements to create
// dynamic and interactive user interfaces, a core concept in web development.
// You can expand on this by adding features like changing brush size,
// clearing the canvas, or saving the drawing.