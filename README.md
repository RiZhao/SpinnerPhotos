# SpinnerPhotos
P1) Make an app with a wheel in the middle of the screen, with a button at the top of the wheel. The button should display where it is on the wheel in degrees(0-360). The user should be able to drag the button around the wheel, and the button text should update to show its new value. Pressing the button will cause the button to rotate around the wheel a random amount, again updating it's displayed value.

P2) Pick a number between 10-20(we'll call it X). Load X random images from the users camera roll into a queue at the bottom of the screen. When the user presses the button in the wheel, as the button rotates around the wheel, the background of the app should display the image in the queue which correlates with the current position of the button. So if X = 10, and if the button has a current value of 0 degrees, the first image in the queue should display as the background image. When the button value changes to 36, the background image should change to the second image in the queue. Every time the user presses the button, X should regenerate and a new selection of images should be loaded  