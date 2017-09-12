//
//  RGBColor.h
//  SmartMoney
//
//  Created by Nang Le on 12/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//define index name for RBG color group
typedef enum RGBRGroupName {
	blackGreyList,
	blueList,
	brownList,
	greenList,
	orangeList,
	redList,
	violetList,
	whiteList,
	yellowList,
	metalList
} RGBRGroupName;

//define index name for RBG Black&Grey color group
typedef enum RGBColorBlackGreyName {
	grey,
	grey_Silver,
	lightGray,
	slateGray,
	slateGray1,
	slateGray3,
	black,
	grey1,
	grey2,
	grey3,
	grey4,
	grey5,
	grey6,
	darkSlateGrey,
	dimGrey,
	lightGrey,
	veryLightGrey,
	freeSpeechGrey
}RGBColorBlackGreyName;

//define index name for RBG Blue color group
typedef enum RGBColorBlueName {
	aliceBlue,
	blueViolet,
	cadetBlue,
	cadetBlue1,
	cadetBlue2,
	cornFlowerBlue1,
	darkSlateBlue,
	darkTurquoise,
	deepSkyBlue,
	deepSkyBlue1,
	deepSkyBlue2,
	deepSkyBlue3,
	dodgerBlue,
	dodgerBlue1,
	dodgerBlue2,
	dodgerBlue3,
	dodgerBlue4,
	lightBlue,
	lightBlue1,
	lightBlue3,
	lightBlue4,
	lightCyan,
	lightCyan1,
	lightCyan2,
	lightCyan3,
	lightSkyBlue,
	lightSkyBlue1,
	lightSkyBlue2,
	lightSkyBlue3,
	lightSkyBlue4,
	lightSlateBlue,
	lightSlateBlue1,
	lightSteelBlue,
	lightSteelBlue1,
	lightSteelBlue2,
	lightSteelBlue3,
	lightSteelBlue4,
	aquamarine,
	mediumBlue,
	mediumSlateBlue,
	mediumTurquoise,
	midnightBlue,
	navyBlue,
	paleTurquoise,
	paleTurquoise1,
	paleTurquoise2,
	paleTurquoise3,
	powderBlue,
	royalBlue,
	royalBlue1,
	royalBlue2,
	royalBlue3,
	royalBlue4,
	skyBlue,
	skyBlue1,
	skyBlue2,
	skyBlue3,
	slateBlue,
	slateBlue1,
	slateBlue2,
	slateBlue3,
	slateBlue4,
	steelBlue,
	steelBlue1,
	steelBlue2,
	steelBlue3,
	steelBlue4,
	steelBlue5,
	steelBlue6,
	mediumAquamarine,
	aquamarine1,
	azure,
	azure1,
	azure2,
	azure3,
	blue,
	blue1,
	blue2,
	blue3,
	aqua,
	cyan,
	cyan1,
	cyan2,
	navy,
	teal,
	turquoise,
	turquoise1,
	turquoise2,
	turquoise3,
	darkSlateGray,
	darkSlateGray1,
	darkSlateGray2,
	darkSlateGray3,
	darkSlateBlue1,
	darkTurquoise1,
	mediumSlateBlue1,
	midnightBlue1,
	navyBlue1,
	neonBlue,
	richBlue,
	slateBlue5,
	summerSky,
	irisBlue,
	freeSpeechBlue
}RGBColorBlueName;
	
//define index name for RBG brown color group
typedef enum RGBColorBrownName{
	rosyBrown,
	rosyBrown1,
	rosyBrown2,
	rosyBrown3,
	rosyBrown4,
	saddleBrown,
	sandyBrown,
	beige,
	brown,
	brown1,
	brown2,
	brown3,
	brown4,
	darkBrown,
	burlywood,
	burlywood1,
	burlywood2,
	bakersChocolate,
	chocolate,
	chocolate1,
	chocolate2,
	chocolate3,
	peru,
	tan_,
	tan1,
	tan2,
	darkTan,
	darkWood,
	lightWood,
	mediumWood,
	newTan,
	sienna5,
	tan3,
	veryDarkBrown
}RGBColorBrownName;

//define index name for RBG green color group
typedef enum RGBColorGreenName{
	darkGreen,
	darkGreen1,
	darkgreencopper,
	darkKhaki,
	darkOliveGreen,
	darkOliveGreen1,
	darkOliveGreen2,
	darkOliveGreen3,
	darkOliveGreen4,
	olive,
	darkSeaGreen,
	darkSeaGreen1,
	darkSeaGreen2,
	darkSeaGreen3,
	forestGreen,
	greenYellow,
	lawnGreen,
	lightSeaGreen,
	limeGreen,
	mediumSeaGreen,
	mediumSpringGreen,
	oliveDrab,
	oliveDrab1,
	oliveDrab2,
	oliveDrab3,
	oliveDrab4,
	paleGreen,
	paleGreen1,
	paleGreen2,
	seaGreen,
	seaGreen1,
	seaGreen2,
	springGreen,
	springGreen1,
	yellowGreen,
	chartreuse,
	chartreuse1,
	chartreuse2,
	green,
	green1,
	khaki,
	khaki1,
	khaki2,
	darkOliveGreen5,
	greenYellow1,
	hunterGreen,
	forestGreen1,
	limeGreen1,
	mediumForestGreen,
	mediumSeaGreen1,
	mediumSpringGreen1,
	paleGreen3,
	seaGreen3,
	springGreen2,
	freeSpeechGreen
}RGBColorGreenName;

//define index name for RBG orange color group
typedef enum RGBColorOrangeName{
	darkOrange,
	darkOrange1,
	darkOrange2,
	darkSalmon,
	lightCoral,
	lightSalmon,
	lightSalmon1,
	peachPuff,
	peachPuff1,
	peachPuff2,
	peachPuff3,
	bisque,
	bisque1,
	bisque2,
	bisque3,
	coral,
	coral1,
	coral2,
	coral3,
	honeydew,
	honeydew1,
	honeydew2,
	honeydew3,
	orange,
	orange1,
	orange2,
	orange3,
	salmon,
	salmon1,
	salmon2,
	salmon3,
	sienna,
	sienna1,
	sienna2,
	sienna3,
	sienna4,
	mandarianOrange,
	orange4,
	orangeRed4
}RGBColorOrangeName;
	
//define index name for RBG Red color group
typedef enum RGBColorRedName{	
	deepPink,
	deepPink1,
	deepPink2,
	deepPink3,
	hotPink,
	hotPink1,
	hotPink2,
	hotPink3,
	indianRed,
	indianRed1,
	indianRed2,
	indianRed3,
	indianRed4,
	lightPink,
	lightPink1,
	lightPink2,
	lightPink3,
	mediumVioletRed,
	mistyRose,
	mistyRose1,
	mistyRose2,
	mistyRose3,
	orangeRed,
	orangeRed1,
	orangeRed2,
	orangeRed3,
	paleVioletRed,
	paleVioletRed1,
	paleVioletRed2,
	paleVioletRed3,
	paleVioletRed4,
	violetRed,
	violetRed1,
	violetRed2,
	violetRed3,
	violetRed4,
	firebrick,
	firebrick1,
	firebrick2,
	firebrick3,
	firebrick4,
	pink,
	pink1,
	pink2,
	pink3,
	flesh,
	feldspar,
	red,
	red1,
	red2,
	red3,
	tomato,
	tomato1,
	tomato2,
	tomato3,
	dustyRose,
	firebrick5,
	indianRed5,
	pink4,
	salmon4,
	scarlet,
	spicyPink,
	freeSpeechRed
}RGBColorRedName;

//define index name for RBG Violet color group
typedef enum RGBColorVioletName{	
	darkOrchid,
	darkOrchid1,
	darkOrchid2,
	darkOrchid3,
	darkOrchid4,
	darkViolet,
	lavenderBlush,
	lavenderBlush1,
	lavenderBlush2,
	lavenderBlush3,
	mediumOrchid,
	mediumOrchid1,
	mediumOrchid2,
	mediumOrchid3,
	mediumOrchid4,
	mediumPurple1,
	darkOrchid5,
	mediumPurple2,
	mediumPurple3,
	mediumPurple4,
	lavender,
	magenta,
	magenta1,
	magenta2,
	magenta3,
	maroon,
	maroon1,
	maroon2,
	maroon3,
	maroon4,
	orchid,
	orchid1,
	orchid2,
	orchid3,
	orchid4,
	plum,
	plum1,
	plum2,
	plum3,
	plum4,
	purple,
	purple1,
	purple2,
	purple3,
	purple4,
	purple5,
	thistle,
	thistle1,
	thistle2,
	thistle4,
	violet,
	violetblue,
	darkPurple,
	maroon5,
	maroon6,
	mediumVioletRed1,
	neonPink,
	plum5,
	turquoise4,
	violet1,
	violetRed5
}RGBColorVioletName;

//define index name for RBG White color group
typedef enum RGBColorWhiteName{	
	antiqueWhite,
	antiqueWhite1,
	antiqueWhite2,
	antiqueWhite3,
	antiqueWhite4,
	floralWhite,
	ghostWhite,
	navajoWhite,
	navajoWhite1,
	navajoWhite2,
	navajoWhite3,
	oldLace,
	whiteSmoke,
	gainsboro,
	ivory,
	ivory1,
	ivory2,
	ivory3,
	linen,
	seashell,
	seashell1,
	seashell2,
	seashell3,
	snow,
	snow1,
	snow2,
	snow3,
	wheat,
	wheat1,
	wheat2,
	wheat3,
	white,
	quartz,
	wheat4
}RGBColorWhiteName;

//define index name for RBG Yellow color group
typedef enum RGBColorYellowName{
	blanchedAlmond,
	darkGoldenrod,
	darkGoldenrod1,
	darkGoldenrod2,
	darkGoldenrod3,
	darkGoldenrod4,
	lemonChiffon,
	lemonChiffon1,
	lemonChiffon2,
	lemonChiffon3,
	lightGoldenrod,
	lightGoldenrod1,
	lightGoldenrod2,
	lightGoldenrod3,
	lightYellow,
	lightYellow1,
	lightYellow2,
	lightYellow3,
	paleGoldenrod,
	papayaWhip,
	cornsilk,
	cornsilk1,
	cornsilk2,
	cornsilk3,
	goldenrod,
	goldenrod1,
	goldenrod2,
	goldenrod3,
	moccasin,
	yellow,
	yellow1,
	yellow2,
	gold,
	gold1,
	gold2,
	gold3,
	goldenrod4,
	mediumGoldenrod,
	yellowGreen1
}RGBColorYellowName;

//define index name for RBG Metal color group
typedef enum RGBColorMetalName{	
	copper,
	coolCopper,
	greenCopper,
	brass,
	bronze,
	bronzeII,
	brightGold,
	oldGold,
	cSSGold,
	gold4,
	silver,
	silver_Grey,
	lightSteelBlue5,
	steelBlue7
} RGBColorMetalName;

@interface RGBColor : NSObject {

}

#pragma mark Shades of Black and Gray
+(UIColor *) grey;
+(UIColor *) grey_Silver;
+(UIColor *) lightGray;
+(UIColor *) slateGray;
+(UIColor *) slateGray1;
+(UIColor *) slateGray3;
+(UIColor *) black;
+(UIColor *) grey1;
+(UIColor *) grey2;
+(UIColor *) grey3;
+(UIColor *) grey4;
+(UIColor *) grey5;
+(UIColor *) grey6;
+(UIColor *) darkSlateGrey;
+(UIColor *) dimGrey;
+(UIColor *) lightGrey;
+(UIColor *) veryLightGrey;
+(UIColor *) freeSpeechGrey;

#pragma mark Shades of Blue

+(UIColor *) aliceBlue;
+(UIColor *) blueViolet;
+(UIColor *) cadetBlue;
+(UIColor *) cadetBlue1;
+(UIColor *) cadetBlue2;
+(UIColor *) cornFlowerBlue1;
+(UIColor *) darkSlateBlue;
+(UIColor *) darkTurquoise;
+(UIColor *) deepSkyBlue;
+(UIColor *) deepSkyBlue1;
+(UIColor *) deepSkyBlue2;
+(UIColor *) deepSkyBlue3;
+(UIColor *) dodgerBlue;
+(UIColor *) dodgerBlue1;
+(UIColor *) dodgerBlue2;
+(UIColor *) dodgerBlue3;
+(UIColor *) dodgerBlue4;
+(UIColor *) lightBlue;
+(UIColor *) lightBlue1;
+(UIColor *) lightBlue3;
+(UIColor *) lightBlue4;
+(UIColor *) lightCyan;
+(UIColor *) lightCyan1;
+(UIColor *) lightCyan2;
+(UIColor *) lightCyan3;
+(UIColor *) lightSkyBlue;
+(UIColor *) lightSkyBlue1;
+(UIColor *) lightSkyBlue2;
+(UIColor *) lightSkyBlue3;
+(UIColor *) lightSkyBlue4;
+(UIColor *) lightSlateBlue;
+(UIColor *) lightSlateBlue1;
+(UIColor *) lightSteelBlue;
+(UIColor *) lightSteelBlue1;
+(UIColor *) lightSteelBlue2;
+(UIColor *) lightSteelBlue3;
+(UIColor *) lightSteelBlue4;
+(UIColor *) aquamarine;
+(UIColor *) mediumBlue;
+(UIColor *) mediumSlateBlue;
+(UIColor *) mediumTurquoise;
+(UIColor *) midnightBlue;
+(UIColor *) navyBlue;
+(UIColor *) paleTurquoise;
+(UIColor *) paleTurquoise1;
+(UIColor *) paleTurquoise2;
+(UIColor *) paleTurquoise3;
+(UIColor *) powderBlue;
+(UIColor *) royalBlue;
+(UIColor *) royalBlue1;
+(UIColor *) royalBlue2;
+(UIColor *) royalBlue3;
+(UIColor *) royalBlue4;
+(UIColor *) skyBlue;
+(UIColor *) skyBlue1;
+(UIColor *) skyBlue2;
+(UIColor *) skyBlue3;
+(UIColor *) slateBlue;
+(UIColor *) slateBlue1;
+(UIColor *) slateBlue2;
+(UIColor *) slateBlue3;
+(UIColor *) slateBlue4;
+(UIColor *) steelBlue;
+(UIColor *) steelBlue1;
+(UIColor *) steelBlue2;
+(UIColor *) steelBlue3;
+(UIColor *) steelBlue4;
+(UIColor *) steelBlue5;
+(UIColor *) steelBlue6;
+(UIColor *) mediumAquamarine;
+(UIColor *) aquamarine1;
+(UIColor *) azure;
+(UIColor *) azure1;
+(UIColor *) azure2;
+(UIColor *) azure3;
+(UIColor *) blue;
+(UIColor *) blue1;
+(UIColor *) blue2;
+(UIColor *) blue3;
+(UIColor *) aqua;
+(UIColor *) cyan;
+(UIColor *) cyan1;
+(UIColor *) cyan2;
+(UIColor *) navy;
+(UIColor *) teal;
+(UIColor *) turquoise;
+(UIColor *) turquoise1;
+(UIColor *) turquoise2;
+(UIColor *) turquoise3;
+(UIColor *) darkSlateGray;
+(UIColor *) darkSlateGray1;
+(UIColor *) darkSlateGray2;
+(UIColor *) darkSlateGray3;
+(UIColor *) darkSlateBlue1;
+(UIColor *) darkTurquoise1;
+(UIColor *) mediumSlateBlue1;
+(UIColor *) midnightBlue1;
+(UIColor *) navyBlue1;
+(UIColor *) neonBlue;
+(UIColor *) richBlue;
+(UIColor *) slateBlue5;
+(UIColor *) summerSky;
+(UIColor *) irisBlue;
+(UIColor *) freeSpeechBlue;

#pragma mark Shades of Brown

+(UIColor *) rosyBrown;
+(UIColor *) rosyBrown1;
+(UIColor *) rosyBrown2;
+(UIColor *) rosyBrown3;
+(UIColor *) rosyBrown4;
+(UIColor *) saddleBrown;
+(UIColor *) sandyBrown;
+(UIColor *) beige;
+(UIColor *) brown;
+(UIColor *) brown1;
+(UIColor *) brown2;
+(UIColor *) brown3;
+(UIColor *) brown4;
+(UIColor *) darkBrown;
+(UIColor *) burlywood;
+(UIColor *) burlywood1;
+(UIColor *) burlywood2;
+(UIColor *) bakersChocolate;
+(UIColor *) chocolate;
+(UIColor *) chocolate1;
+(UIColor *) chocolate2;
+(UIColor *) chocolate3;
+(UIColor *) peru;
+(UIColor *) tan;
+(UIColor *) tan1;
+(UIColor *) tan2;
+(UIColor *) darkTan;
+(UIColor *) darkWood;
+(UIColor *) lightWood;
+(UIColor *) mediumWood;
+(UIColor *) newTan;
+(UIColor *) sienna5;
+(UIColor *) tan3;
+(UIColor *) veryDarkBrown;

#pragma mark Shades of Green

+(UIColor *) darkGreen;
+(UIColor *) darkGreen1;
+(UIColor *) darkgreencopper;
+(UIColor *) darkKhaki;
+(UIColor *) darkOliveGreen;
+(UIColor *) darkOliveGreen1;
+(UIColor *) darkOliveGreen2;
+(UIColor *) darkOliveGreen3;
+(UIColor *) darkOliveGreen4;
+(UIColor *) olive;
+(UIColor *) darkSeaGreen;
+(UIColor *) darkSeaGreen1;
+(UIColor *) darkSeaGreen2;
+(UIColor *) darkSeaGreen3;
+(UIColor *) forestGreen;
+(UIColor *) greenYellow;
+(UIColor *) lawnGreen;
+(UIColor *) lightSeaGreen;
+(UIColor *) limeGreen;
+(UIColor *) mediumSeaGreen;
+(UIColor *) mediumSpringGreen;
+(UIColor *) oliveDrab;
+(UIColor *) oliveDrab1;
+(UIColor *) oliveDrab2;
+(UIColor *) oliveDrab3;
+(UIColor *) oliveDrab4;
+(UIColor *) paleGreen;
+(UIColor *) paleGreen1;
+(UIColor *) paleGreen2;
+(UIColor *) seaGreen;
+(UIColor *) seaGreen1;
+(UIColor *) seaGreen2;
+(UIColor *) springGreen;
+(UIColor *) springGreen1;
+(UIColor *) yellowGreen;
+(UIColor *) chartreuse;
+(UIColor *) chartreuse1;
+(UIColor *) chartreuse2;
+(UIColor *) green;
+(UIColor *) green1;
+(UIColor *) khaki;
+(UIColor *) khaki1;
+(UIColor *) khaki2;
+(UIColor *) darkOliveGreen5;
+(UIColor *) greenYellow1;
+(UIColor *) hunterGreen;
+(UIColor *) forestGreen1;
+(UIColor *) limeGreen1;
+(UIColor *) mediumForestGreen;
+(UIColor *) mediumSeaGreen1;
+(UIColor *) mediumSpringGreen1;
+(UIColor *) paleGreen3;
+(UIColor *) seaGreen3;
+(UIColor *) springGreen2;
+(UIColor *) freeSpeechGreen;

#pragma mark Shades of Orange

+(UIColor *) darkOrange;
+(UIColor *) darkOrange1;
+(UIColor *) darkOrange2;
+(UIColor *) darkSalmon;
+(UIColor *) lightCoral;
+(UIColor *) lightSalmon;
+(UIColor *) lightSalmon1;
+(UIColor *) peachPuff;
+(UIColor *) peachPuff1;
+(UIColor *) peachPuff2;
+(UIColor *) peachPuff3;
+(UIColor *) bisque;
+(UIColor *) bisque1;
+(UIColor *) bisque2;
+(UIColor *) bisque3;
+(UIColor *) coral;
+(UIColor *) coral1;
+(UIColor *) coral2;
+(UIColor *) coral3;
+(UIColor *) honeydew;
+(UIColor *) honeydew1;
+(UIColor *) honeydew2;
+(UIColor *) honeydew3;
+(UIColor *) orange;
+(UIColor *) orange1;
+(UIColor *) orange2;
+(UIColor *) orange3;
+(UIColor *) salmon;
+(UIColor *) salmon1;
+(UIColor *) salmon2;
+(UIColor *) salmon3;
+(UIColor *) sienna;
+(UIColor *) sienna1;
+(UIColor *) sienna2;
+(UIColor *) sienna3;
+(UIColor *) sienna4;
+(UIColor *) mandarianOrange;
+(UIColor *) orange4;
+(UIColor *) orangeRed4;

#pragma mark Shades of Red

+(UIColor *) deepPink;
+(UIColor *) deepPink1;
+(UIColor *) deepPink2;
+(UIColor *) deepPink3;
+(UIColor *) hotPink;
+(UIColor *) hotPink1;
+(UIColor *) hotPink2;
+(UIColor *) hotPink3;
+(UIColor *) indianRed;
+(UIColor *) indianRed1;
+(UIColor *) indianRed2;
+(UIColor *) indianRed3;
+(UIColor *) indianRed4;
+(UIColor *) lightPink;
+(UIColor *) lightPink1;
+(UIColor *) lightPink2;
+(UIColor *) lightPink3;
+(UIColor *) mediumVioletRed;
+(UIColor *) mistyRose;
+(UIColor *) mistyRose1;
+(UIColor *) mistyRose2;
+(UIColor *) mistyRose3;
+(UIColor *) orangeRed;
+(UIColor *) orangeRed1;
+(UIColor *) orangeRed2;
+(UIColor *) orangeRed3;
+(UIColor *) paleVioletRed;
+(UIColor *) paleVioletRed1;
+(UIColor *) paleVioletRed2;
+(UIColor *) paleVioletRed3;
+(UIColor *) paleVioletRed4;
+(UIColor *) violetRed;
+(UIColor *) violetRed1;
+(UIColor *) violetRed2;
+(UIColor *) violetRed3;
+(UIColor *) violetRed4;
+(UIColor *) firebrick;
+(UIColor *) firebrick1;
+(UIColor *) firebrick2;
+(UIColor *) firebrick3;
+(UIColor *) firebrick4;
+(UIColor *) pink;
+(UIColor *) pink1;
+(UIColor *) pink2;
+(UIColor *) pink3;
+(UIColor *) flesh;
+(UIColor *) feldspar;
+(UIColor *) red;
+(UIColor *) red1;
+(UIColor *) red2;
+(UIColor *) red3;
+(UIColor *) tomato;
+(UIColor *) tomato1;
+(UIColor *) tomato2;
+(UIColor *) tomato3;
+(UIColor *) dustyRose;
+(UIColor *) firebrick5;
+(UIColor *) indianRed5;
+(UIColor *) pink4;
+(UIColor *) salmon4;
+(UIColor *) scarlet;
+(UIColor *) spicyPink;
+(UIColor *) freeSpeechRed;

#pragma mark Shades of Violet

+(UIColor *) darkOrchid;
+(UIColor *) darkOrchid1;
+(UIColor *) darkOrchid2;
+(UIColor *) darkOrchid3;
+(UIColor *) darkOrchid4;
+(UIColor *) darkViolet;
+(UIColor *) lavenderBlush;
+(UIColor *) lavenderBlush1;
+(UIColor *) lavenderBlush2;
+(UIColor *) lavenderBlush3;
+(UIColor *) mediumOrchid;
+(UIColor *) mediumOrchid1;
+(UIColor *) mediumOrchid2;
+(UIColor *) mediumOrchid3;
+(UIColor *) mediumOrchid4;
+(UIColor *) mediumPurple1;
+(UIColor *) darkOrchid5;
+(UIColor *) mediumPurple2;
+(UIColor *) mediumPurple3;
+(UIColor *) mediumPurple4;
+(UIColor *) lavender;
+(UIColor *) magenta;
+(UIColor *) magenta1;
+(UIColor *) magenta2;
+(UIColor *) magenta3;
+(UIColor *) maroon;
+(UIColor *) maroon1;
+(UIColor *) maroon2;
+(UIColor *) maroon3;
+(UIColor *) maroon4;
+(UIColor *) orchid;
+(UIColor *) orchid1;
+(UIColor *) orchid2;
+(UIColor *) orchid3;
+(UIColor *) orchid4;
+(UIColor *) plum;
+(UIColor *) plum1;
+(UIColor *) plum2;
+(UIColor *) plum3;
+(UIColor *) plum4;
+(UIColor *) purple;
+(UIColor *) purple1;
+(UIColor *) purple2;
+(UIColor *) purple3;
+(UIColor *) purple4;
+(UIColor *) purple5;
+(UIColor *) thistle;
+(UIColor *) thistle1;
+(UIColor *) thistle2;
+(UIColor *) thistle4;
+(UIColor *) violet;
+(UIColor *) violetblue;
+(UIColor *) darkPurple;
+(UIColor *) maroon5;
+(UIColor *) maroon6;
+(UIColor *) mediumVioletRed1;
+(UIColor *) neonPink;
+(UIColor *) plum5;
+(UIColor *) turquoise4;
+(UIColor *) violet1;
+(UIColor *) violetRed5;

#pragma mark Shades of White

+(UIColor *) antiqueWhite;
+(UIColor *) antiqueWhite1;
+(UIColor *) antiqueWhite2;
+(UIColor *) antiqueWhite3;
+(UIColor *) antiqueWhite4;
+(UIColor *) floralWhite;
+(UIColor *) ghostWhite;
+(UIColor *) navajoWhite;
+(UIColor *) navajoWhite1;
+(UIColor *) navajoWhite2;
+(UIColor *) navajoWhite3;
+(UIColor *) oldLace;
+(UIColor *) whiteSmoke;
+(UIColor *) gainsboro;
+(UIColor *) ivory;
+(UIColor *) ivory1;
+(UIColor *) ivory2;
+(UIColor *) ivory3;
+(UIColor *) linen;
+(UIColor *) seashell;
+(UIColor *) seashell1;
+(UIColor *) seashell2;
+(UIColor *) seashell3;
+(UIColor *) snow;
+(UIColor *) snow1;
+(UIColor *) snow2;
+(UIColor *) snow3;
+(UIColor *) wheat;
+(UIColor *) wheat1;
+(UIColor *) wheat2;
+(UIColor *) wheat3;
+(UIColor *) white;
+(UIColor *) quartz;
+(UIColor *) wheat4;

#pragma mark Shades of Yellow

+(UIColor *) blanchedAlmond;
+(UIColor *) darkGoldenrod;
+(UIColor *) darkGoldenrod1;
+(UIColor *) darkGoldenrod2;
+(UIColor *) darkGoldenrod3;
+(UIColor *) darkGoldenrod4;
+(UIColor *) lemonChiffon;
+(UIColor *) lemonChiffon1;
+(UIColor *) lemonChiffon2;
+(UIColor *) lemonChiffon3;
+(UIColor *) lightGoldenrod;
+(UIColor *) lightGoldenrod1;
+(UIColor *) lightGoldenrod2;
+(UIColor *) lightGoldenrod3;
+(UIColor *) lightYellow;
+(UIColor *) lightYellow1;
+(UIColor *) lightYellow2;
+(UIColor *) lightYellow3;
+(UIColor *) paleGoldenrod;
+(UIColor *) papayaWhip;
+(UIColor *) cornsilk;
+(UIColor *) cornsilk1;
+(UIColor *) cornsilk2;
+(UIColor *) cornsilk3;
+(UIColor *) goldenrod;
+(UIColor *) goldenrod1;
+(UIColor *) goldenrod2;
+(UIColor *) goldenrod3;
+(UIColor *) moccasin;
+(UIColor *) yellow;
+(UIColor *) yellow1;
+(UIColor *) yellow2;
+(UIColor *) gold;
+(UIColor *) gold1;
+(UIColor *) gold2;
+(UIColor *) gold3;
+(UIColor *) goldenrod4;
+(UIColor *) mediumGoldenrod;
+(UIColor *) yellowGreen1;

#pragma mark Shades of Metal

+(UIColor *) copper;
+(UIColor *) coolCopper;
+(UIColor *) greenCopper;
+(UIColor *) brass;
+(UIColor *) bronze;
+(UIColor *) bronzeII;
+(UIColor *) brightGold;
+(UIColor *) oldGold;
+(UIColor *) cSSGold;
+(UIColor *) gold4;
+(UIColor *) silver;
+(UIColor *) silver_Grey;
+(UIColor *) lightSteelBlue5;
+(UIColor *) steelBlue7;

#pragma mark common methods
+(UIColor *)RGBColorBlackGreyByIndex:(RGBColorBlackGreyName)colorIndex;
+(UIColor *)RGBColorBlueByIndex:(RGBColorBlueName)colorIndex;
+(UIColor *)RGBColorBrownByIndex:(RGBColorBrownName)colorIndex;
+(UIColor *)RGBColorGreenByIndex:(RGBColorGreenName)colorIndex;
+(UIColor *)RGBColorOrangeByIndex:(RGBColorOrangeName)colorIndex;
+(UIColor *)RGBColorRedByIndex:(RGBColorRedName)colorIndex;
+(UIColor *)RGBColorVioletByIndex:(RGBColorVioletName)colorIndex;
+(UIColor *)RGBColorWhiteByIndex:(RGBColorWhiteName)colorIndex;
+(UIColor *)RGBColorYellowByIndex:(RGBColorYellowName)colorIndex;
+(UIColor *)RGBColorMetalByIndex:(RGBColorMetalName)colorIndex;

+(NSMutableArray *)getRGBColorBlackGreyList;
+(NSMutableArray *)getRGBColorBlueList;
+(NSMutableArray *)getRGBColorBrownList;
+(NSMutableArray *)getRGBColorGreenList;
+(NSMutableArray *)getRGBColorOrangeList;
+(NSMutableArray *)getRGBColorRedList;
+(NSMutableArray *)getRGBColorVioletList;
+(NSMutableArray *)getRGBColorWhiteList;
+(NSMutableArray *)getRGBColorYellowList;
+(NSMutableArray *)getRGBColorMetalList;

+(NSMutableArray *)getRGBColorGroupList;

+(UIColor *)fontColorForRGBGroupList:(NSInteger)groupList atItem:(NSInteger)row;

+(UIColor *)colorForGroup:(NSInteger)groupID atIndex:(NSInteger)index;
@end
