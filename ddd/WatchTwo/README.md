//Michael Sylvester

A quick walkthrough 
	
	1)  The app will not load with any images from cloudkit 
	2)  The watch interflace without any images since it loads from NSUser Defaults
	3)  The watch glance will open with a stock image until one is favorited
	4)  When editing a photo in the photo view controller, you can load an image from the local images on the simulator by clicking the info button:
		a)  you can then add a filter by pressing the filter button
		b)  you can add a moustache if the app can detect a mouth
		c)  hitting save will create a low resoultion thumbail image and place it in a small image view below the main image view.  This will also put the image in cloudkit and send it to the watch interface controller
	5)  In the main app when viewing the collection view you can tap an image to favorite it.




Attributions:
https://www.raywenderlich.com/117249/watchos-2-tutorial-part-2-tables
Nick Pann
Andrew CloudKit Lecture
http://www.appcoda.com/core-image-introduction/