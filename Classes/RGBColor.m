//
//  RGBColor.m
//  SmartMoney
//
//  Created by Nang Le on 12/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RGBColor.h"


@implementation RGBColor

#pragma mark Shades of Black and Gray 
+(UIColor *) grey{ //R;G;B Dec: 84;84;84, //Hex:  545454
return [UIColor colorWithRed:(CGFloat)84/255 green:(CGFloat)84/255 blue:(CGFloat)84/255 alpha:1];
}
+(UIColor *) grey_Silver{ //R;G;B Dec: 192;192;192, //Hex:  C0C0C0
return [UIColor colorWithRed:(CGFloat)192/255 green:(CGFloat)192/255 blue:(CGFloat)192/255 alpha:1];
}
+(UIColor *) lightGray{ //R;G;B Dec: 211;211;211, //Hex:  D3D3D3
return [UIColor colorWithRed:(CGFloat)211/255 green:(CGFloat)211/255 blue:(CGFloat)211/255 alpha:1];
}
+(UIColor *) slateGray{ //R;G;B Dec: 112;128;144, //Hex:  708090
return [UIColor colorWithRed:(CGFloat)112/255 green:(CGFloat)128/255 blue:(CGFloat)144/255 alpha:1];
}
+(UIColor *) slateGray1{ //R;G;B Dec: 198;226;255, //Hex:  C6E2FF
return [UIColor colorWithRed:(CGFloat)198/255 green:(CGFloat)226/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) slateGray3{ //R;G;B Dec: 159;182;205, //Hex:  9FB6CD
return [UIColor colorWithRed:(CGFloat)159/255 green:(CGFloat)182/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) black{ //R;G;B Dec: 0;0;0, //Hex:  0
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) grey1{ //R;G;B Dec: 38;38;38, //Hex:  262626
return [UIColor colorWithRed:(CGFloat)38/255 green:(CGFloat)38/255 blue:(CGFloat)38/255 alpha:1];
}
+(UIColor *) grey2{ //R;G;B Dec: 105;105;105, //Hex:  696969
return [UIColor colorWithRed:(CGFloat)105/255 green:(CGFloat)105/255 blue:(CGFloat)105/255 alpha:1];
}
+(UIColor *) grey3{ //R;G;B Dec: 186;186;186, //Hex:  BABABA
return [UIColor colorWithRed:(CGFloat)186/255 green:(CGFloat)186/255 blue:(CGFloat)186/255 alpha:1];
}
+(UIColor *) grey4{ //R;G;B Dec: 224;224;224, //Hex:  E0E0E0
return [UIColor colorWithRed:(CGFloat)224/255 green:(CGFloat)224/255 blue:(CGFloat)224/255 alpha:1];
}
+(UIColor *) grey5{ //R;G;B Dec: 240;240;240, //Hex:  F0F0F0
return [UIColor colorWithRed:(CGFloat)240/255 green:(CGFloat)240/255 blue:(CGFloat)240/255 alpha:1];
}
+(UIColor *) grey6{ //R;G;B Dec: 252;252;252, //Hex:  FCFCFC
return [UIColor colorWithRed:(CGFloat)252/255 green:(CGFloat)252/255 blue:(CGFloat)252/255 alpha:1];
}
+(UIColor *) darkSlateGrey{ //R;G;B Dec: 47;79;79, //Hex:  2F4F4F
return [UIColor colorWithRed:(CGFloat)47/255 green:(CGFloat)79/255 blue:(CGFloat)79/255 alpha:1];
}
+(UIColor *) dimGrey{ //R;G;B Dec: 84;84;84, //Hex:  545454
return [UIColor colorWithRed:(CGFloat)84/255 green:(CGFloat)84/255 blue:(CGFloat)84/255 alpha:1];
}
+(UIColor *) lightGrey{ //R;G;B Dec: 219;219;112, //Hex:  DBDB70
return [UIColor colorWithRed:(CGFloat)219/255 green:(CGFloat)219/255 blue:(CGFloat)112/255 alpha:1];
}
+(UIColor *) veryLightGrey{ //R;G;B Dec: 205;205;205, //Hex:  CDCDCD
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)205/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) freeSpeechGrey{ //R;G;B Dec: 99;86;136, //Hex:  635688
return [UIColor colorWithRed:(CGFloat)99/255 green:(CGFloat)86/255 blue:(CGFloat)136/255 alpha:1];
}

#pragma mark Shades of Blue

+(UIColor *) aliceBlue{ //R;G;B Dec: 240;248;255, //Hex:  F0F8FF
return [UIColor colorWithRed:(CGFloat)240/255 green:(CGFloat)248/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) blueViolet{ //R;G;B Dec: 138;43;226, //Hex:  8A2BE2
return [UIColor colorWithRed:(CGFloat)138/255 green:(CGFloat)43/255 blue:(CGFloat)226/255 alpha:1];
}
+(UIColor *) cadetBlue{ //R;G;B Dec: 95;159;159, //Hex:  5F9F9F
return [UIColor colorWithRed:(CGFloat)95/255 green:(CGFloat)159/255 blue:(CGFloat)159/255 alpha:1];
}
+(UIColor *) cadetBlue1{ //R;G;B Dec: 142;229;238, //Hex:  8EE5EE
return [UIColor colorWithRed:(CGFloat)142/255 green:(CGFloat)229/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) cadetBlue2{ //R;G;B Dec: 122;197;205, //Hex:  7AC5CD
return [UIColor colorWithRed:(CGFloat)122/255 green:(CGFloat)197/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) cornFlowerBlue1{ //R;G;B Dec: 100;149;237, //Hex:  6495ED
return [UIColor colorWithRed:(CGFloat)100/255 green:(CGFloat)149/255 blue:(CGFloat)237/255 alpha:1];
}
+(UIColor *) darkSlateBlue{ //R;G;B Dec: 72;61;139, //Hex:  483D8B
return [UIColor colorWithRed:(CGFloat)72/255 green:(CGFloat)61/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) darkTurquoise{ //R;G;B Dec: 0;206;209, //Hex:  00CED1
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)206/255 blue:(CGFloat)209/255 alpha:1];
}
+(UIColor *) deepSkyBlue{ //R;G;B Dec: 0;191;255, //Hex:  00BFFF
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)191/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) deepSkyBlue1{ //R;G;B Dec: 0;191;255, //Hex:  00BFFF
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)191/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) deepSkyBlue2{ //R;G;B Dec: 0;154;205, //Hex:  009ACD
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)154/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) deepSkyBlue3{ //R;G;B Dec: 0;104;139, //Hex:  00688B
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)104/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) dodgerBlue{ //R;G;B Dec: 30;144;255, //Hex:  1E90FF
return [UIColor colorWithRed:(CGFloat)30/255 green:(CGFloat)144/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) dodgerBlue1{ //R;G;B Dec: 28;134;238, //Hex:  1C86EE
return [UIColor colorWithRed:(CGFloat)28/255 green:(CGFloat)134/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) dodgerBlue2{ //R;G;B Dec: 24;116;205, //Hex:  1874CD
return [UIColor colorWithRed:(CGFloat)24/255 green:(CGFloat)116/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) dodgerBlue3{ //R;G;B Dec: 16;78;139, //Hex:  104E8B
return [UIColor colorWithRed:(CGFloat)16/255 green:(CGFloat)78/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) dodgerBlue4{ //R;G;B Dec: 170;187;204, //Hex:  AABBCC
return [UIColor colorWithRed:(CGFloat)170/255 green:(CGFloat)187/255 blue:(CGFloat)204/255 alpha:1];
}
+(UIColor *) lightBlue{ //R;G;B Dec: 173;216;230, //Hex:  ADD8E6
return [UIColor colorWithRed:(CGFloat)173/255 green:(CGFloat)216/255 blue:(CGFloat)230/255 alpha:1];
}
+(UIColor *) lightBlue1{ //R;G;B Dec: 191;239;255, //Hex:  BFEFFF
return [UIColor colorWithRed:(CGFloat)191/255 green:(CGFloat)239/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) lightBlue3{ //R;G;B Dec: 154;192;205, //Hex:  9AC0CD
return [UIColor colorWithRed:(CGFloat)154/255 green:(CGFloat)192/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) lightBlue4{ //R;G;B Dec: 104;131;139, //Hex:  68838B
return [UIColor colorWithRed:(CGFloat)104/255 green:(CGFloat)131/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) lightCyan{ //R;G;B Dec: 224;255;255, //Hex:  E0FFFF
return [UIColor colorWithRed:(CGFloat)224/255 green:(CGFloat)255/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) lightCyan1{ //R;G;B Dec: 209;238;238, //Hex:  D1EEEE
return [UIColor colorWithRed:(CGFloat)209/255 green:(CGFloat)238/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) lightCyan2{ //R;G;B Dec: 180;205;205, //Hex:  B4CDCD
return [UIColor colorWithRed:(CGFloat)180/255 green:(CGFloat)205/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) lightCyan3{ //R;G;B Dec: 122;139;139, //Hex:  7A8B8B
return [UIColor colorWithRed:(CGFloat)122/255 green:(CGFloat)139/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) lightSkyBlue{ //R;G;B Dec: 135;206;250, //Hex:  87CEFA
return [UIColor colorWithRed:(CGFloat)135/255 green:(CGFloat)206/255 blue:(CGFloat)250/255 alpha:1];
}
+(UIColor *) lightSkyBlue1{ //R;G;B Dec: 176;226;255, //Hex:  B0E2FF
return [UIColor colorWithRed:(CGFloat)176/255 green:(CGFloat)226/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) lightSkyBlue2{ //R;G;B Dec: 164;211;238, //Hex:  A4D3EE
return [UIColor colorWithRed:(CGFloat)164/255 green:(CGFloat)211/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) lightSkyBlue3{ //R;G;B Dec: 141;182;205, //Hex:  8DB6CD
return [UIColor colorWithRed:(CGFloat)141/255 green:(CGFloat)182/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) lightSkyBlue4{ //R;G;B Dec: 96;123;139, //Hex:  607B8B
return [UIColor colorWithRed:(CGFloat)96/255 green:(CGFloat)123/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) lightSlateBlue{ //R;G;B Dec: 132;112;255, //Hex:  8470FF
return [UIColor colorWithRed:(CGFloat)132/255 green:(CGFloat)112/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) lightSlateBlue1{ //R;G;B Dec: 153;204;255, //Hex:  99CCFF
return [UIColor colorWithRed:(CGFloat)153/255 green:(CGFloat)204/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) lightSteelBlue{ //R;G;B Dec: 176;196;222, //Hex:  B0C4DE
return [UIColor colorWithRed:(CGFloat)176/255 green:(CGFloat)196/255 blue:(CGFloat)222/255 alpha:1];
}
+(UIColor *) lightSteelBlue1{ //R;G;B Dec: 202;225;255, //Hex:  CAE1FF
return [UIColor colorWithRed:(CGFloat)202/255 green:(CGFloat)225/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) lightSteelBlue2{ //R;G;B Dec: 188;210;238, //Hex:  BCD2EE
return [UIColor colorWithRed:(CGFloat)188/255 green:(CGFloat)210/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) lightSteelBlue3{ //R;G;B Dec: 162;181;205, //Hex:  A2B5CD
return [UIColor colorWithRed:(CGFloat)162/255 green:(CGFloat)181/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) lightSteelBlue4{ //R;G;B Dec: 110;123;139, //Hex:  6E7B8B
return [UIColor colorWithRed:(CGFloat)110/255 green:(CGFloat)123/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) aquamarine{ //R;G;B Dec: 112;219;147, //Hex:  70DB93
return [UIColor colorWithRed:(CGFloat)112/255 green:(CGFloat)219/255 blue:(CGFloat)147/255 alpha:1];
}
+(UIColor *) mediumBlue{ //R;G;B Dec: 0;0;205, //Hex:  0000CD
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) mediumSlateBlue{ //R;G;B Dec: 123;104;238, //Hex:  7B68EE
return [UIColor colorWithRed:(CGFloat)123/255 green:(CGFloat)104/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) mediumTurquoise{ //R;G;B Dec: 72;209;204, //Hex:  48D1CC
return [UIColor colorWithRed:(CGFloat)72/255 green:(CGFloat)209/255 blue:(CGFloat)204/255 alpha:1];
}
+(UIColor *) midnightBlue{ //R;G;B Dec: 25;25;112, //Hex:  191970
return [UIColor colorWithRed:(CGFloat)25/255 green:(CGFloat)25/255 blue:(CGFloat)112/255 alpha:1];
}
+(UIColor *) navyBlue{ //R;G;B Dec: 0;0;128, //Hex:  80
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)128/255 alpha:1];
}
+(UIColor *) paleTurquoise{ //R;G;B Dec: 175;238;238, //Hex:  AFEEEE
return [UIColor colorWithRed:(CGFloat)175/255 green:(CGFloat)238/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) paleTurquoise1{ //R;G;B Dec: 187;255;255, //Hex:  BBFFFF
return [UIColor colorWithRed:(CGFloat)187/255 green:(CGFloat)255/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) paleTurquoise2{ //R;G;B Dec: 150;205;205, //Hex:  96CDCD
return [UIColor colorWithRed:(CGFloat)150/255 green:(CGFloat)205/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) paleTurquoise3{ //R;G;B Dec: 102;139;139, //Hex:  668B8B
return [UIColor colorWithRed:(CGFloat)102/255 green:(CGFloat)139/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) powderBlue{ //R;G;B Dec: 176;224;230, //Hex:  B0E0E6
return [UIColor colorWithRed:(CGFloat)176/255 green:(CGFloat)224/255 blue:(CGFloat)230/255 alpha:1];
}
+(UIColor *) royalBlue{ //R;G;B Dec: 65;105;225, //Hex:  41690
return [UIColor colorWithRed:(CGFloat)65/255 green:(CGFloat)105/255 blue:(CGFloat)225/255 alpha:1];
}
+(UIColor *) royalBlue1{ //R;G;B Dec: 72;118;255, //Hex:  4876FF
return [UIColor colorWithRed:(CGFloat)72/255 green:(CGFloat)118/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) royalBlue2{ //R;G;B Dec: 58;95;205, //Hex:  3A5FCD
return [UIColor colorWithRed:(CGFloat)58/255 green:(CGFloat)95/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) royalBlue3{ //R;G;B Dec: 39;64;139, //Hex:  27408B
return [UIColor colorWithRed:(CGFloat)39/255 green:(CGFloat)64/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) royalBlue4{ //R;G;B Dec: 0;34;102, //Hex:  2266
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)34/255 blue:(CGFloat)102/255 alpha:1];
}
+(UIColor *) skyBlue{ //R;G;B Dec: 135;206;235, //Hex:  87CEEB
return [UIColor colorWithRed:(CGFloat)135/255 green:(CGFloat)206/255 blue:(CGFloat)235/255 alpha:1];
}
+(UIColor *) skyBlue1{ //R;G;B Dec: 126;192;238, //Hex:  7EC0EE
return [UIColor colorWithRed:(CGFloat)126/255 green:(CGFloat)192/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) skyBlue2{ //R;G;B Dec: 108;166;205, //Hex:  6CA6CD
return [UIColor colorWithRed:(CGFloat)108/255 green:(CGFloat)166/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) skyBlue3{ //R;G;B Dec: 74;112;139, //Hex:  4A708B
return [UIColor colorWithRed:(CGFloat)74/255 green:(CGFloat)112/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) slateBlue{ //R;G;B Dec: 106;90;205, //Hex:  6A5ACD
return [UIColor colorWithRed:(CGFloat)106/255 green:(CGFloat)90/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) slateBlue1{ //R;G;B Dec: 131;111;255, //Hex:  836FFF
return [UIColor colorWithRed:(CGFloat)131/255 green:(CGFloat)111/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) slateBlue2{ //R;G;B Dec: 122;103;238, //Hex:  7A67EE
return [UIColor colorWithRed:(CGFloat)122/255 green:(CGFloat)103/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) slateBlue3{ //R;G;B Dec: 105;89;205, //Hex:  6959CD
return [UIColor colorWithRed:(CGFloat)105/255 green:(CGFloat)89/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) slateBlue4{ //R;G;B Dec: 71;60;139, //Hex:  473C8B
return [UIColor colorWithRed:(CGFloat)71/255 green:(CGFloat)60/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) steelBlue{ //R;G;B Dec: 70;130;180, //Hex:  4682B4
return [UIColor colorWithRed:(CGFloat)70/255 green:(CGFloat)130/255 blue:(CGFloat)180/255 alpha:1];
}
+(UIColor *) steelBlue1{ //R;G;B Dec: 92;172;238, //Hex:  5CACEE
return [UIColor colorWithRed:(CGFloat)92/255 green:(CGFloat)172/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) steelBlue2{ //R;G;B Dec: 79;148;205, //Hex:  4F94CD
return [UIColor colorWithRed:(CGFloat)79/255 green:(CGFloat)148/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) steelBlue3{ //R;G;B Dec: 54;100;139, //Hex:  36648B
return [UIColor colorWithRed:(CGFloat)54/255 green:(CGFloat)100/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) steelBlue4{ //R;G;B Dec: 51;102;153, //Hex:  336699
return [UIColor colorWithRed:(CGFloat)51/255 green:(CGFloat)102/255 blue:(CGFloat)153/255 alpha:1];
}
+(UIColor *) steelBlue5{ //R;G;B Dec: 51;153;204, //Hex:  3399CC
return [UIColor colorWithRed:(CGFloat)51/255 green:(CGFloat)153/255 blue:(CGFloat)204/255 alpha:1];
}
+(UIColor *) steelBlue6{ //R;G;B Dec: 102;153;204, //Hex:  6699CC
return [UIColor colorWithRed:(CGFloat)102/255 green:(CGFloat)153/255 blue:(CGFloat)204/255 alpha:1];
}
+(UIColor *) mediumAquamarine{ //R;G;B Dec: 102;205;170, //Hex:  66CDAA
return [UIColor colorWithRed:(CGFloat)102/255 green:(CGFloat)205/255 blue:(CGFloat)170/255 alpha:1];
}
+(UIColor *) aquamarine1{ //R;G;B Dec: 69;139;116, //Hex:  458B74
return [UIColor colorWithRed:(CGFloat)69/255 green:(CGFloat)139/255 blue:(CGFloat)116/255 alpha:1];
}
+(UIColor *) azure{ //R;G;B Dec: 240;255;255, //Hex:  F0FFFF
return [UIColor colorWithRed:(CGFloat)240/255 green:(CGFloat)255/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) azure1{ //R;G;B Dec: 224;238;238, //Hex:  E0EEEE
return [UIColor colorWithRed:(CGFloat)224/255 green:(CGFloat)238/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) azure2{ //R;G;B Dec: 193;205;205, //Hex:  C1CDCD
return [UIColor colorWithRed:(CGFloat)193/255 green:(CGFloat)205/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) azure3{ //R;G;B Dec: 131;139;139, //Hex:  838B8B
return [UIColor colorWithRed:(CGFloat)131/255 green:(CGFloat)139/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) blue{ //R;G;B Dec: 0;0;255, //Hex:  0000FF
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) blue1{ //R;G;B Dec: 0;0;238, //Hex:  0000EE
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) blue2{ //R;G;B Dec: 0;0;205, //Hex:  0000CD
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) blue3{ //R;G;B Dec: 0;0;139, //Hex:  00008B
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) aqua{ //R;G;B Dec: 0;255;255, //Hex:  00FFFF
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)255/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) cyan{ //R;G;B Dec: 0;238;238, //Hex:  00EEEE
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)238/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) cyan1{ //R;G;B Dec: 0;205;205, //Hex:  00CDCD
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)205/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) cyan2{ //R;G;B Dec: 0;139;139, //Hex:  008B8B
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)139/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) navy{ //R;G;B Dec: 0;0;128, //Hex:  80
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)128/255 alpha:1];
}
+(UIColor *) teal{ //R;G;B Dec: 0;128;128, //Hex:  8080
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)128/255 blue:(CGFloat)128/255 alpha:1];
}
+(UIColor *) turquoise{ //R;G;B Dec: 64;224;208, //Hex:  40E0D0
return [UIColor colorWithRed:(CGFloat)64/255 green:(CGFloat)224/255 blue:(CGFloat)208/255 alpha:1];
}
+(UIColor *) turquoise1{ //R;G;B Dec: 0;229;238, //Hex:  00E5EE
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)229/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) turquoise2{ //R;G;B Dec: 0;197;205, //Hex:  00C5CD
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)197/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) turquoise3{ //R;G;B Dec: 0;134;139, //Hex:  00868B
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)134/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) darkSlateGray{ //R;G;B Dec: 47;79;79, //Hex:  2F4F4F
return [UIColor colorWithRed:(CGFloat)47/255 green:(CGFloat)79/255 blue:(CGFloat)79/255 alpha:1];
}
+(UIColor *) darkSlateGray1{ //R;G;B Dec: 141;238;238, //Hex:  8DEEEE
return [UIColor colorWithRed:(CGFloat)141/255 green:(CGFloat)238/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) darkSlateGray2{ //R;G;B Dec: 121;205;205, //Hex:  79CDCD
return [UIColor colorWithRed:(CGFloat)121/255 green:(CGFloat)205/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) darkSlateGray3{ //R;G;B Dec: 82;139;139, //Hex:  528B8B
return [UIColor colorWithRed:(CGFloat)82/255 green:(CGFloat)139/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) darkSlateBlue1{ //R;G;B Dec: 36;24;130, //Hex:  241882
return [UIColor colorWithRed:(CGFloat)36/255 green:(CGFloat)24/255 blue:(CGFloat)130/255 alpha:1];
}
+(UIColor *) darkTurquoise1{ //R;G;B Dec: 112;147;219, //Hex:  7093DB
return [UIColor colorWithRed:(CGFloat)112/255 green:(CGFloat)147/255 blue:(CGFloat)219/255 alpha:1];
}
+(UIColor *) mediumSlateBlue1{ //R;G;B Dec: 127;0;255, //Hex:  7F00FF
return [UIColor colorWithRed:(CGFloat)127/255 green:(CGFloat)0/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) midnightBlue1{ //R;G;B Dec: 47;47;79, //Hex:  2F2F4F
return [UIColor colorWithRed:(CGFloat)47/255 green:(CGFloat)47/255 blue:(CGFloat)79/255 alpha:1];
}
+(UIColor *) navyBlue1{ //R;G;B Dec: 35;35;142, //Hex:  23238E
return [UIColor colorWithRed:(CGFloat)35/255 green:(CGFloat)35/255 blue:(CGFloat)142/255 alpha:1];
}
+(UIColor *) neonBlue{ //R;G;B Dec: 77;77;255, //Hex:  4D4DFF
return [UIColor colorWithRed:(CGFloat)77/255 green:(CGFloat)77/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) richBlue{ //R;G;B Dec: 89;89;171, //Hex:  5959AB
return [UIColor colorWithRed:(CGFloat)89/255 green:(CGFloat)89/255 blue:(CGFloat)171/255 alpha:1];
}
+(UIColor *) slateBlue5{ //R;G;B Dec: 0;127;255, //Hex:  007FFF
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)127/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) summerSky{ //R;G;B Dec: 56;176;222, //Hex:  38B0DE
return [UIColor colorWithRed:(CGFloat)56/255 green:(CGFloat)176/255 blue:(CGFloat)222/255 alpha:1];
}
+(UIColor *) irisBlue{ //R;G;B Dec: 3;180;200, //Hex:  03B4C8
return [UIColor colorWithRed:(CGFloat)3/255 green:(CGFloat)180/255 blue:(CGFloat)200/255 alpha:1];
}
+(UIColor *) freeSpeechBlue{ //R;G;B Dec: 65;86;197, //Hex:  4156C5
return [UIColor colorWithRed:(CGFloat)65/255 green:(CGFloat)86/255 blue:(CGFloat)197/255 alpha:1];
}

#pragma mark Shades of Brown

+(UIColor *) rosyBrown{ //R;G;B Dec: 188;143;143, //Hex:  BC8F8F
return [UIColor colorWithRed:(CGFloat)188/255 green:(CGFloat)143/255 blue:(CGFloat)143/255 alpha:1];
}
+(UIColor *) rosyBrown1{ //R;G;B Dec: 255;193;193, //Hex:  FFC1C1
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)193/255 blue:(CGFloat)193/255 alpha:1];
}
+(UIColor *) rosyBrown2{ //R;G;B Dec: 238;180;180, //Hex:  EEB4B4
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)180/255 blue:(CGFloat)180/255 alpha:1];
}
+(UIColor *) rosyBrown3{ //R;G;B Dec: 205;155;155, //Hex:  CD9B9B
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)155/255 blue:(CGFloat)155/255 alpha:1];
}
+(UIColor *) rosyBrown4{ //R;G;B Dec: 139;105;105, //Hex:  8B6969
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)105/255 blue:(CGFloat)105/255 alpha:1];
}
+(UIColor *) saddleBrown{ //R;G;B Dec: 139;69;19, //Hex:  8B4513
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)69/255 blue:(CGFloat)19/255 alpha:1];
}
+(UIColor *) sandyBrown{ //R;G;B Dec: 244;164;96, //Hex:  F4A460
return [UIColor colorWithRed:(CGFloat)244/255 green:(CGFloat)164/255 blue:(CGFloat)96/255 alpha:1];
}
+(UIColor *) beige{ //R;G;B Dec: 245;245;220, //Hex:  F5F5DC
return [UIColor colorWithRed:(CGFloat)245/255 green:(CGFloat)245/255 blue:(CGFloat)220/255 alpha:1];
}
+(UIColor *) brown{ //R;G;B Dec: 165;42;42, //Hex:  A52A2A
return [UIColor colorWithRed:(CGFloat)165/255 green:(CGFloat)42/255 blue:(CGFloat)42/255 alpha:1];
}
+(UIColor *) brown1{ //R;G;B Dec: 255;64;64, //Hex:  FF4040
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)64/255 blue:(CGFloat)64/255 alpha:1];
}
+(UIColor *) brown2{ //R;G;B Dec: 238;59;59, //Hex:  EE3B3B
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)59/255 blue:(CGFloat)59/255 alpha:1];
}
+(UIColor *) brown3{ //R;G;B Dec: 205;51;51, //Hex:  CD3333
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)51/255 blue:(CGFloat)51/255 alpha:1];
}
+(UIColor *) brown4{ //R;G;B Dec: 139;35;35, //Hex:  8B2323
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)35/255 blue:(CGFloat)35/255 alpha:1];
}
+(UIColor *) darkBrown{ //R;G;B Dec: 92;64;51, //Hex:  5C4033
return [UIColor colorWithRed:(CGFloat)92/255 green:(CGFloat)64/255 blue:(CGFloat)51/255 alpha:1];
}
+(UIColor *) burlywood{ //R;G;B Dec: 222;184;135, //Hex:  DEB887
return [UIColor colorWithRed:(CGFloat)222/255 green:(CGFloat)184/255 blue:(CGFloat)135/255 alpha:1];
}
+(UIColor *) burlywood1{ //R;G;B Dec: 255;211;155, //Hex:  FFD39B
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)211/255 blue:(CGFloat)155/255 alpha:1];
}
+(UIColor *) burlywood2{ //R;G;B Dec: 139;115;85, //Hex:  8B7355
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)115/255 blue:(CGFloat)85/255 alpha:1];
}
+(UIColor *) bakersChocolate{ //R;G;B Dec: 92;51;23, //Hex:  5C3317
return [UIColor colorWithRed:(CGFloat)92/255 green:(CGFloat)51/255 blue:(CGFloat)23/255 alpha:1];
}
+(UIColor *) chocolate{ //R;G;B Dec: 210;105;30, //Hex:  D2691E
return [UIColor colorWithRed:(CGFloat)210/255 green:(CGFloat)105/255 blue:(CGFloat)30/255 alpha:1];
}
+(UIColor *) chocolate1{ //R;G;B Dec: 255;127;36, //Hex:  FF7F24
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)127/255 blue:(CGFloat)36/255 alpha:1];
}
+(UIColor *) chocolate2{ //R;G;B Dec: 238;118;33, //Hex:  EE7621
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)118/255 blue:(CGFloat)33/255 alpha:1];
}
+(UIColor *) chocolate3{ //R;G;B Dec: 139;69;19, //Hex:  8B4513
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)69/255 blue:(CGFloat)19/255 alpha:1];
}
+(UIColor *) peru{ //R;G;B Dec: 205;133;63, //Hex:  CD853F
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)133/255 blue:(CGFloat)63/255 alpha:1];
}
+(UIColor *) tan{ //R;G;B Dec: 210;180;140, //Hex:  D2B48C
return [UIColor colorWithRed:(CGFloat)210/255 green:(CGFloat)180/255 blue:(CGFloat)140/255 alpha:1];
}
+(UIColor *) tan1{ //R;G;B Dec: 255;165;79, //Hex:  FFA54F
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)165/255 blue:(CGFloat)79/255 alpha:1];
}
+(UIColor *) tan2{ //R;G;B Dec: 205;133;63, //Hex:  CD853F
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)133/255 blue:(CGFloat)63/255 alpha:1];
}
+(UIColor *) darkTan{ //R;G;B Dec: 151;105;79, //Hex:  97694F
return [UIColor colorWithRed:(CGFloat)151/255 green:(CGFloat)105/255 blue:(CGFloat)79/255 alpha:1];
}
+(UIColor *) darkWood{ //R;G;B Dec: 133;94;66, //Hex:  8.55E+44
return [UIColor colorWithRed:(CGFloat)133/255 green:(CGFloat)94/255 blue:(CGFloat)66/255 alpha:1];
}
+(UIColor *) lightWood{ //R;G;B Dec: 133;99;99, //Hex:  856363
return [UIColor colorWithRed:(CGFloat)133/255 green:(CGFloat)99/255 blue:(CGFloat)99/255 alpha:1];
}
+(UIColor *) mediumWood{ //R;G;B Dec: 166;128;100, //Hex:  A68064
return [UIColor colorWithRed:(CGFloat)166/255 green:(CGFloat)128/255 blue:(CGFloat)100/255 alpha:1];
}
+(UIColor *) newTan{ //R;G;B Dec: 235;199;158, //Hex:  EBC79E
return [UIColor colorWithRed:(CGFloat)235/255 green:(CGFloat)199/255 blue:(CGFloat)158/255 alpha:1];
}
+(UIColor *) sienna5{ //R;G;B Dec: 142;107;35, //Hex:  8E6B23
return [UIColor colorWithRed:(CGFloat)142/255 green:(CGFloat)107/255 blue:(CGFloat)35/255 alpha:1];
}
+(UIColor *) tan3{ //R;G;B Dec: 219;147;112, //Hex:  DB9370
return [UIColor colorWithRed:(CGFloat)219/255 green:(CGFloat)147/255 blue:(CGFloat)112/255 alpha:1];
}
+(UIColor *) veryDarkBrown{ //R;G;B Dec: 92;64;51, //Hex:  5C4033
return [UIColor colorWithRed:(CGFloat)92/255 green:(CGFloat)64/255 blue:(CGFloat)51/255 alpha:1];
}

#pragma mark Shades of Green

+(UIColor *) darkGreen{ //R;G;B Dec: 47;79;47, //Hex:  2F4F2F
return [UIColor colorWithRed:(CGFloat)47/255 green:(CGFloat)79/255 blue:(CGFloat)47/255 alpha:1];
}
+(UIColor *) darkGreen1{ //R;G;B Dec: 0;100;0, //Hex:  6400
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)100/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) darkgreencopper{ //R;G;B Dec: 74;118;110, //Hex:  4A766E
return [UIColor colorWithRed:(CGFloat)74/255 green:(CGFloat)118/255 blue:(CGFloat)110/255 alpha:1];
}
+(UIColor *) darkKhaki{ //R;G;B Dec: 189;183;107, //Hex:  BDB76B
return [UIColor colorWithRed:(CGFloat)189/255 green:(CGFloat)183/255 blue:(CGFloat)107/255 alpha:1];
}
+(UIColor *) darkOliveGreen{ //R;G;B Dec: 85;107;47, //Hex:  556B2F
return [UIColor colorWithRed:(CGFloat)85/255 green:(CGFloat)107/255 blue:(CGFloat)47/255 alpha:1];
}
+(UIColor *) darkOliveGreen1{ //R;G;B Dec: 202;255;112, //Hex:  CAFF70
return [UIColor colorWithRed:(CGFloat)202/255 green:(CGFloat)255/255 blue:(CGFloat)112/255 alpha:1];
}
+(UIColor *) darkOliveGreen2{ //R;G;B Dec: 188;238;104, //Hex:  BCEE68
return [UIColor colorWithRed:(CGFloat)188/255 green:(CGFloat)238/255 blue:(CGFloat)104/255 alpha:1];
}
+(UIColor *) darkOliveGreen3{ //R;G;B Dec: 162;205;90, //Hex:  A2CD5A
return [UIColor colorWithRed:(CGFloat)162/255 green:(CGFloat)205/255 blue:(CGFloat)90/255 alpha:1];
}
+(UIColor *) darkOliveGreen4{ //R;G;B Dec: 110;139;61, //Hex:  6E8B3D
return [UIColor colorWithRed:(CGFloat)110/255 green:(CGFloat)139/255 blue:(CGFloat)61/255 alpha:1];
}
+(UIColor *) olive{ //R;G;B Dec: 128;128;0, //Hex:  808000
return [UIColor colorWithRed:(CGFloat)128/255 green:(CGFloat)128/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) darkSeaGreen{ //R;G;B Dec: 143;188;143, //Hex:  8FBC8F
return [UIColor colorWithRed:(CGFloat)143/255 green:(CGFloat)188/255 blue:(CGFloat)143/255 alpha:1];
}
+(UIColor *) darkSeaGreen1{ //R;G;B Dec: 193;255;193, //Hex:  C1FFC1
return [UIColor colorWithRed:(CGFloat)193/255 green:(CGFloat)255/255 blue:(CGFloat)193/255 alpha:1];
}
+(UIColor *) darkSeaGreen2{ //R;G;B Dec: 180;238;180, //Hex:  B4EEB4
return [UIColor colorWithRed:(CGFloat)180/255 green:(CGFloat)238/255 blue:(CGFloat)180/255 alpha:1];
}
+(UIColor *) darkSeaGreen3{ //R;G;B Dec: 105;139;105, //Hex:  698B69
return [UIColor colorWithRed:(CGFloat)105/255 green:(CGFloat)139/255 blue:(CGFloat)105/255 alpha:1];
}
+(UIColor *) forestGreen{ //R;G;B Dec: 34;139;34, //Hex:  228B22
return [UIColor colorWithRed:(CGFloat)34/255 green:(CGFloat)139/255 blue:(CGFloat)34/255 alpha:1];
}
+(UIColor *) greenYellow{ //R;G;B Dec: 173;255;47, //Hex:  ADFF2F
return [UIColor colorWithRed:(CGFloat)173/255 green:(CGFloat)255/255 blue:(CGFloat)47/255 alpha:1];
}
+(UIColor *) lawnGreen{ //R;G;B Dec: 124;252;0, //Hex:  7CFC00
return [UIColor colorWithRed:(CGFloat)124/255 green:(CGFloat)252/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) lightSeaGreen{ //R;G;B Dec: 32;178;170, //Hex:  20B2AA
return [UIColor colorWithRed:(CGFloat)32/255 green:(CGFloat)178/255 blue:(CGFloat)170/255 alpha:1];
}
+(UIColor *) limeGreen{ //R;G;B Dec: 50;205;50, //Hex:  32CD32
return [UIColor colorWithRed:(CGFloat)50/255 green:(CGFloat)205/255 blue:(CGFloat)50/255 alpha:1];
}
+(UIColor *) mediumSeaGreen{ //R;G;B Dec: 60;179;113, //Hex:  3CB371
return [UIColor colorWithRed:(CGFloat)60/255 green:(CGFloat)179/255 blue:(CGFloat)113/255 alpha:1];
}
+(UIColor *) mediumSpringGreen{ //R;G;B Dec: 0;250;154, //Hex:  00FA9A
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)250/255 blue:(CGFloat)154/255 alpha:1];
}
+(UIColor *) oliveDrab{ //R;G;B Dec: 107;142;35, //Hex:  6B8E23
return [UIColor colorWithRed:(CGFloat)107/255 green:(CGFloat)142/255 blue:(CGFloat)35/255 alpha:1];
}
+(UIColor *) oliveDrab1{ //R;G;B Dec: 192;255;62, //Hex:  C0FF3E
return [UIColor colorWithRed:(CGFloat)192/255 green:(CGFloat)255/255 blue:(CGFloat)62/255 alpha:1];
}
+(UIColor *) oliveDrab2{ //R;G;B Dec: 179;238;58, //Hex:  B3EE3A
return [UIColor colorWithRed:(CGFloat)179/255 green:(CGFloat)238/255 blue:(CGFloat)58/255 alpha:1];
}
+(UIColor *) oliveDrab3{ //R;G;B Dec: 154;205;50, //Hex:  9ACD32
return [UIColor colorWithRed:(CGFloat)154/255 green:(CGFloat)205/255 blue:(CGFloat)50/255 alpha:1];
}
+(UIColor *) oliveDrab4{ //R;G;B Dec: 105;139;34, //Hex:  698B22
return [UIColor colorWithRed:(CGFloat)105/255 green:(CGFloat)139/255 blue:(CGFloat)34/255 alpha:1];
}
+(UIColor *) paleGreen{ //R;G;B Dec: 152;251;152, //Hex:  98FB98
return [UIColor colorWithRed:(CGFloat)152/255 green:(CGFloat)251/255 blue:(CGFloat)152/255 alpha:1];
}
+(UIColor *) paleGreen1{ //R;G;B Dec: 124;205;124, //Hex:  7CCD7C
return [UIColor colorWithRed:(CGFloat)124/255 green:(CGFloat)205/255 blue:(CGFloat)124/255 alpha:1];
}
+(UIColor *) paleGreen2{ //R;G;B Dec: 84;139;84, //Hex:  548B54
return [UIColor colorWithRed:(CGFloat)84/255 green:(CGFloat)139/255 blue:(CGFloat)84/255 alpha:1];
}
+(UIColor *) seaGreen{ //R;G;B Dec: 46;139;87, //Hex:  2E8B57
return [UIColor colorWithRed:(CGFloat)46/255 green:(CGFloat)139/255 blue:(CGFloat)87/255 alpha:1];
}
+(UIColor *) seaGreen1{ //R;G;B Dec: 84;255;159, //Hex:  54FF9F
return [UIColor colorWithRed:(CGFloat)84/255 green:(CGFloat)255/255 blue:(CGFloat)159/255 alpha:1];
}
+(UIColor *) seaGreen2{ //R;G;B Dec: 67;205;128, //Hex:  43CD80
return [UIColor colorWithRed:(CGFloat)67/255 green:(CGFloat)205/255 blue:(CGFloat)128/255 alpha:1];
}
+(UIColor *) springGreen{ //R;G;B Dec: 0;255;127, //Hex:  00FF7F
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)255/255 blue:(CGFloat)127/255 alpha:1];
}
+(UIColor *) springGreen1{ //R;G;B Dec: 0;139;69, //Hex:  008B45
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)139/255 blue:(CGFloat)69/255 alpha:1];
}
+(UIColor *) yellowGreen{ //R;G;B Dec: 154;205;50, //Hex:  9ACD32
return [UIColor colorWithRed:(CGFloat)154/255 green:(CGFloat)205/255 blue:(CGFloat)50/255 alpha:1];
}
+(UIColor *) chartreuse{ //R;G;B Dec: 127;255;0, //Hex:  7FFF00
return [UIColor colorWithRed:(CGFloat)127/255 green:(CGFloat)255/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) chartreuse1{ //R;G;B Dec: 102;205;0, //Hex:  66CD00
return [UIColor colorWithRed:(CGFloat)102/255 green:(CGFloat)205/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) chartreuse2{ //R;G;B Dec: 69;139;0, //Hex:  458B00
return [UIColor colorWithRed:(CGFloat)69/255 green:(CGFloat)139/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) green{ //R;G;B Dec: 0;128;0, //Hex:  8000
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)128/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) green1{ //R;G;B Dec: 0;139;0, //Hex:  008B00
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)139/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) khaki{ //R;G;B Dec: 240;230;140, //Hex:  F0E68C
return [UIColor colorWithRed:(CGFloat)240/255 green:(CGFloat)230/255 blue:(CGFloat)140/255 alpha:1];
}
+(UIColor *) khaki1{ //R;G;B Dec: 205;198;115, //Hex:  CDC673
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)198/255 blue:(CGFloat)115/255 alpha:1];
}
+(UIColor *) khaki2{ //R;G;B Dec: 139;134;78, //Hex:  8B864E
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)134/255 blue:(CGFloat)78/255 alpha:1];
}
+(UIColor *) darkOliveGreen5{ //R;G;B Dec: 79;79;47, //Hex:  4F4F2F
return [UIColor colorWithRed:(CGFloat)79/255 green:(CGFloat)79/255 blue:(CGFloat)47/255 alpha:1];
}
+(UIColor *) greenYellow1{ //R;G;B Dec: 209;146;117, //Hex:  D19275
return [UIColor colorWithRed:(CGFloat)209/255 green:(CGFloat)146/255 blue:(CGFloat)117/255 alpha:1];
}
+(UIColor *) hunterGreen{ //R;G;B Dec: 142;35;35, //Hex:  8E2323
return [UIColor colorWithRed:(CGFloat)142/255 green:(CGFloat)35/255 blue:(CGFloat)35/255 alpha:1];
}
+(UIColor *) forestGreen1{ //R;G;B Dec: 35;142;35, //Hex:  2.38E+25
return [UIColor colorWithRed:(CGFloat)35/255 green:(CGFloat)142/255 blue:(CGFloat)35/255 alpha:1];
}
+(UIColor *) limeGreen1{ //R;G;B Dec: 209;146;117, //Hex:  D19275
return [UIColor colorWithRed:(CGFloat)209/255 green:(CGFloat)146/255 blue:(CGFloat)117/255 alpha:1];
}
+(UIColor *) mediumForestGreen{ //R;G;B Dec: 219;219;112, //Hex:  DBDB70
return [UIColor colorWithRed:(CGFloat)219/255 green:(CGFloat)219/255 blue:(CGFloat)112/255 alpha:1];
}
+(UIColor *) mediumSeaGreen1{ //R;G;B Dec: 66;111;66, //Hex:  426F42
return [UIColor colorWithRed:(CGFloat)66/255 green:(CGFloat)111/255 blue:(CGFloat)66/255 alpha:1];
}
+(UIColor *) mediumSpringGreen1{ //R;G;B Dec: 127;255;0, //Hex:  7FFF00
return [UIColor colorWithRed:(CGFloat)127/255 green:(CGFloat)255/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) paleGreen3{ //R;G;B Dec: 143;188;143, //Hex:  8FBC8F
return [UIColor colorWithRed:(CGFloat)143/255 green:(CGFloat)188/255 blue:(CGFloat)143/255 alpha:1];
}
+(UIColor *) seaGreen3{ //R;G;B Dec: 35;142;104, //Hex:  2.38E+70
return [UIColor colorWithRed:(CGFloat)35/255 green:(CGFloat)142/255 blue:(CGFloat)104/255 alpha:1];
}
+(UIColor *) springGreen2{ //R;G;B Dec: 0;255;127, //Hex:  00FF7F
return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)255/255 blue:(CGFloat)127/255 alpha:1];
}
+(UIColor *) freeSpeechGreen{ //R;G;B Dec: 9;249;17, //Hex:  09F911
return [UIColor colorWithRed:(CGFloat)9/255 green:(CGFloat)249/255 blue:(CGFloat)17/255 alpha:1];
}

#pragma mark Shades of Orange

+(UIColor *) darkOrange{ //R;G;B Dec: 255;140;0, //Hex:  FF8C00
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)140/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) darkOrange1{ //R;G;B Dec: 205;102;0, //Hex:  CD6600
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)102/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) darkOrange2{ //R;G;B Dec: 139;69;0, //Hex:  8B4500
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)69/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) darkSalmon{ //R;G;B Dec: 233;150;122, //Hex:  E9967A
return [UIColor colorWithRed:(CGFloat)233/255 green:(CGFloat)150/255 blue:(CGFloat)122/255 alpha:1];
}
+(UIColor *) lightCoral{ //R;G;B Dec: 240;128;128, //Hex:  F08080
return [UIColor colorWithRed:(CGFloat)240/255 green:(CGFloat)128/255 blue:(CGFloat)128/255 alpha:1];
}
+(UIColor *) lightSalmon{ //R;G;B Dec: 255;160;122, //Hex:  FFA07A
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)160/255 blue:(CGFloat)122/255 alpha:1];
}
+(UIColor *) lightSalmon1{ //R;G;B Dec: 139;87;66, //Hex:  8B5742
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)87/255 blue:(CGFloat)66/255 alpha:1];
}
+(UIColor *) peachPuff{ //R;G;B Dec: 255;218;185, //Hex:  FFDAB9
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)218/255 blue:(CGFloat)185/255 alpha:1];
}
+(UIColor *) peachPuff1{ //R;G;B Dec: 238;203;173, //Hex:  EECBAD
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)203/255 blue:(CGFloat)173/255 alpha:1];
}
+(UIColor *) peachPuff2{ //R;G;B Dec: 205;175;149, //Hex:  CDAF95
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)175/255 blue:(CGFloat)149/255 alpha:1];
}
+(UIColor *) peachPuff3{ //R;G;B Dec: 139;119;101, //Hex:  8B7765
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)119/255 blue:(CGFloat)101/255 alpha:1];
}
+(UIColor *) bisque{ //R;G;B Dec: 255;228;196, //Hex:  FFE4C4
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)228/255 blue:(CGFloat)196/255 alpha:1];
}
+(UIColor *) bisque1{ //R;G;B Dec: 238;213;183, //Hex:  EED5B7
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)213/255 blue:(CGFloat)183/255 alpha:1];
}
+(UIColor *) bisque2{ //R;G;B Dec: 205;183;158, //Hex:  CDB79E
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)183/255 blue:(CGFloat)158/255 alpha:1];
}
+(UIColor *) bisque3{ //R;G;B Dec: 139;125;107, //Hex:  8B7D6B
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)125/255 blue:(CGFloat)107/255 alpha:1];
}
+(UIColor *) coral{ //R;G;B Dec: 255;127;0, //Hex:  FF7F00
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)127/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) coral1{ //R;G;B Dec: 238;106;80, //Hex:  EE6A50
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)106/255 blue:(CGFloat)80/255 alpha:1];
}
+(UIColor *) coral2{ //R;G;B Dec: 205;91;69, //Hex:  CD5B45
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)91/255 blue:(CGFloat)69/255 alpha:1];
}
+(UIColor *) coral3{ //R;G;B Dec: 139;62;47, //Hex:  8B3E2F
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)62/255 blue:(CGFloat)47/255 alpha:1];
}
+(UIColor *) honeydew{ //R;G;B Dec: 240;255;240, //Hex:  F0FFF0
return [UIColor colorWithRed:(CGFloat)240/255 green:(CGFloat)255/255 blue:(CGFloat)240/255 alpha:1];
}
+(UIColor *) honeydew1{ //R;G;B Dec: 224;238;224, //Hex:  E0EEE0
return [UIColor colorWithRed:(CGFloat)224/255 green:(CGFloat)238/255 blue:(CGFloat)224/255 alpha:1];
}
+(UIColor *) honeydew2{ //R;G;B Dec: 193;205;193, //Hex:  C1CDC1
return [UIColor colorWithRed:(CGFloat)193/255 green:(CGFloat)205/255 blue:(CGFloat)193/255 alpha:1];
}
+(UIColor *) honeydew3{ //R;G;B Dec: 131;139;131, //Hex:  838B83
return [UIColor colorWithRed:(CGFloat)131/255 green:(CGFloat)139/255 blue:(CGFloat)131/255 alpha:1];
}
+(UIColor *) orange{ //R;G;B Dec: 255;165;0, //Hex:  FFA500
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)165/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) orange1{ //R;G;B Dec: 238;154;0, //Hex:  EE9A00
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)154/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) orange2{ //R;G;B Dec: 205;133;0, //Hex:  CD8500
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)133/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) orange3{ //R;G;B Dec: 139;90;0, //Hex:  8B5A00
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)90/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) salmon{ //R;G;B Dec: 250;128;114, //Hex:  FA8072
return [UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)128/255 blue:(CGFloat)114/255 alpha:1];
}
+(UIColor *) salmon1{ //R;G;B Dec: 255;140;105, //Hex:  FF8C69
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)140/255 blue:(CGFloat)105/255 alpha:1];
}
+(UIColor *) salmon2{ //R;G;B Dec: 205;112;84, //Hex:  CD7054
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)112/255 blue:(CGFloat)84/255 alpha:1];
}
+(UIColor *) salmon3{ //R;G;B Dec: 139;76;57, //Hex:  8B4C39
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)76/255 blue:(CGFloat)57/255 alpha:1];
}
+(UIColor *) sienna{ //R;G;B Dec: 160;82;45, //Hex:  A0522D
return [UIColor colorWithRed:(CGFloat)160/255 green:(CGFloat)82/255 blue:(CGFloat)45/255 alpha:1];
}
+(UIColor *) sienna1{ //R;G;B Dec: 255;130;71, //Hex:  FF8247
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)130/255 blue:(CGFloat)71/255 alpha:1];
}
+(UIColor *) sienna2{ //R;G;B Dec: 238;121;66, //Hex:  EE7942
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)121/255 blue:(CGFloat)66/255 alpha:1];
}
+(UIColor *) sienna3{ //R;G;B Dec: 205;104;57, //Hex:  CD6839
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)104/255 blue:(CGFloat)57/255 alpha:1];
}
+(UIColor *) sienna4{ //R;G;B Dec: 139;71;38, //Hex:  8B4726
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)71/255 blue:(CGFloat)38/255 alpha:1];
}
+(UIColor *) mandarianOrange{ //R;G;B Dec: 142;35;35, //Hex:  8E2323
return [UIColor colorWithRed:(CGFloat)142/255 green:(CGFloat)35/255 blue:(CGFloat)35/255 alpha:1];
}
+(UIColor *) orange4{ //R;G;B Dec: 255;127;0, //Hex:  FF7F00
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)127/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) orangeRed4{ //R;G;B Dec: 255;36;0, //Hex:  FF2400
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)36/255 blue:(CGFloat)0/255 alpha:1];
}

#pragma mark Shades of Red

+(UIColor *) deepPink{ //R;G;B Dec: 255;20;147, //Hex:  FF1493
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)20/255 blue:(CGFloat)147/255 alpha:1];
}
+(UIColor *) deepPink1{ //R;G;B Dec: 238;18;137, //Hex:  EE1289
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)18/255 blue:(CGFloat)137/255 alpha:1];
}
+(UIColor *) deepPink2{ //R;G;B Dec: 205;16;118, //Hex:  CD1076
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)16/255 blue:(CGFloat)118/255 alpha:1];
}
+(UIColor *) deepPink3{ //R;G;B Dec: 139;10;80, //Hex:  8B0A50
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)10/255 blue:(CGFloat)80/255 alpha:1];
}
+(UIColor *) hotPink{ //R;G;B Dec: 255;105;180, //Hex:  FF69B4
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)105/255 blue:(CGFloat)180/255 alpha:1];
}
+(UIColor *) hotPink1{ //R;G;B Dec: 238;106;167, //Hex:  EE6AA7
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)106/255 blue:(CGFloat)167/255 alpha:1];
}
+(UIColor *) hotPink2{ //R;G;B Dec: 205;96;144, //Hex:  CD6090
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)96/255 blue:(CGFloat)144/255 alpha:1];
}
+(UIColor *) hotPink3{ //R;G;B Dec: 139;58;98, //Hex:  8B3A62
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)58/255 blue:(CGFloat)98/255 alpha:1];
}
+(UIColor *) indianRed{ //R;G;B Dec: 205;92;92, //Hex:  CD5C5C
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)92/255 blue:(CGFloat)92/255 alpha:1];
}
+(UIColor *) indianRed1{ //R;G;B Dec: 255;106;106, //Hex:  FF6A6A
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)106/255 blue:(CGFloat)106/255 alpha:1];
}
+(UIColor *) indianRed2{ //R;G;B Dec: 238;99;99, //Hex:  EE6363
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)99/255 blue:(CGFloat)99/255 alpha:1];
}
+(UIColor *) indianRed3{ //R;G;B Dec: 205;85;85, //Hex:  CD5555
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)85/255 blue:(CGFloat)85/255 alpha:1];
}
+(UIColor *) indianRed4{ //R;G;B Dec: 139;58;58, //Hex:  8B3A3A
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)58/255 blue:(CGFloat)58/255 alpha:1];
}
+(UIColor *) lightPink{ //R;G;B Dec: 255;182;193, //Hex:  FFB6C1
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)182/255 blue:(CGFloat)193/255 alpha:1];
}
+(UIColor *) lightPink1{ //R;G;B Dec: 238;162;173, //Hex:  EEA2AD
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)162/255 blue:(CGFloat)173/255 alpha:1];
}
+(UIColor *) lightPink2{ //R;G;B Dec: 205;140;149, //Hex:  CD8C95
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)140/255 blue:(CGFloat)149/255 alpha:1];
}
+(UIColor *) lightPink3{ //R;G;B Dec: 139;95;101, //Hex:  8B5F65
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)95/255 blue:(CGFloat)101/255 alpha:1];
}
+(UIColor *) mediumVioletRed{ //R;G;B Dec: 199;21;133, //Hex:  C71585
return [UIColor colorWithRed:(CGFloat)199/255 green:(CGFloat)21/255 blue:(CGFloat)133/255 alpha:1];
}
+(UIColor *) mistyRose{ //R;G;B Dec: 255;228;225, //Hex:  FFE4E1
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)228/255 blue:(CGFloat)225/255 alpha:1];
}
+(UIColor *) mistyRose1{ //R;G;B Dec: 238;213;210, //Hex:  EED5D2
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)213/255 blue:(CGFloat)210/255 alpha:1];
}
+(UIColor *) mistyRose2{ //R;G;B Dec: 205;183;181, //Hex:  CDB7B5
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)183/255 blue:(CGFloat)181/255 alpha:1];
}
+(UIColor *) mistyRose3{ //R;G;B Dec: 139;125;123, //Hex:  8B7D7B
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)125/255 blue:(CGFloat)123/255 alpha:1];
}
+(UIColor *) orangeRed{ //R;G;B Dec: 255;69;0, //Hex:  FF4500
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)69/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) orangeRed1{ //R;G;B Dec: 238;64;0, //Hex:  EE4000
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)64/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) orangeRed2{ //R;G;B Dec: 205;55;0, //Hex:  CD3700
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)55/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) orangeRed3{ //R;G;B Dec: 139;37;0, //Hex:  8B2500
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)37/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) paleVioletRed{ //R;G;B Dec: 219;112;147, //Hex:  DB7093
return [UIColor colorWithRed:(CGFloat)219/255 green:(CGFloat)112/255 blue:(CGFloat)147/255 alpha:1];
}
+(UIColor *) paleVioletRed1{ //R;G;B Dec: 255;130;171, //Hex:  FF82AB
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)130/255 blue:(CGFloat)171/255 alpha:1];
}
+(UIColor *) paleVioletRed2{ //R;G;B Dec: 238;121;159, //Hex:  EE799F
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)121/255 blue:(CGFloat)159/255 alpha:1];
}
+(UIColor *) paleVioletRed3{ //R;G;B Dec: 205;104;137, //Hex:  CD6889
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)104/255 blue:(CGFloat)137/255 alpha:1];
}
+(UIColor *) paleVioletRed4{ //R;G;B Dec: 139;71;93, //Hex:  8B475D
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)71/255 blue:(CGFloat)93/255 alpha:1];
}
+(UIColor *) violetRed{ //R;G;B Dec: 208;32;144, //Hex:  D02090
return [UIColor colorWithRed:(CGFloat)208/255 green:(CGFloat)32/255 blue:(CGFloat)144/255 alpha:1];
}
+(UIColor *) violetRed1{ //R;G;B Dec: 255;62;150, //Hex:  FF3E96
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)62/255 blue:(CGFloat)150/255 alpha:1];
}
+(UIColor *) violetRed2{ //R;G;B Dec: 238;58;140, //Hex:  EE3A8C
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)58/255 blue:(CGFloat)140/255 alpha:1];
}
+(UIColor *) violetRed3{ //R;G;B Dec: 205;50;120, //Hex:  CD3278
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)50/255 blue:(CGFloat)120/255 alpha:1];
}
+(UIColor *) violetRed4{ //R;G;B Dec: 139;34;82, //Hex:  8B2252
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)34/255 blue:(CGFloat)82/255 alpha:1];
}
+(UIColor *) firebrick{ //R;G;B Dec: 178;34;34, //Hex:  B22222
return [UIColor colorWithRed:(CGFloat)178/255 green:(CGFloat)34/255 blue:(CGFloat)34/255 alpha:1];
}
+(UIColor *) firebrick1{ //R;G;B Dec: 255;48;48, //Hex:  FF3030
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)48/255 blue:(CGFloat)48/255 alpha:1];
}
+(UIColor *) firebrick2{ //R;G;B Dec: 238;44;44, //Hex:  EE2C2C
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)44/255 blue:(CGFloat)44/255 alpha:1];
}
+(UIColor *) firebrick3{ //R;G;B Dec: 205;38;38, //Hex:  CD2626
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)38/255 blue:(CGFloat)38/255 alpha:1];
}
+(UIColor *) firebrick4{ //R;G;B Dec: 139;26;26, //Hex:  8B1A1A
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)26/255 blue:(CGFloat)26/255 alpha:1];
}
+(UIColor *) pink{ //R;G;B Dec: 255;192;203, //Hex:  FFC0CB
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)192/255 blue:(CGFloat)203/255 alpha:1];
}
+(UIColor *) pink1{ //R;G;B Dec: 238;169;184, //Hex:  EEA9B8
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)169/255 blue:(CGFloat)184/255 alpha:1];
}
+(UIColor *) pink2{ //R;G;B Dec: 205;145;158, //Hex:  CD919E
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)145/255 blue:(CGFloat)158/255 alpha:1];
}
+(UIColor *) pink3{ //R;G;B Dec: 139;99;108, //Hex:  8B636C
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)99/255 blue:(CGFloat)108/255 alpha:1];
}
+(UIColor *) flesh{ //R;G;B Dec: 245;204;176, //Hex:  F5CCB0
return [UIColor colorWithRed:(CGFloat)245/255 green:(CGFloat)204/255 blue:(CGFloat)176/255 alpha:1];
}
+(UIColor *) feldspar{ //R;G;B Dec: 209;146;117, //Hex:  D19275
return [UIColor colorWithRed:(CGFloat)209/255 green:(CGFloat)146/255 blue:(CGFloat)117/255 alpha:1];
}
+(UIColor *) red{ //R;G;B Dec: 255;0;0, //Hex:  FF0000
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)0/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) red1{ //R;G;B Dec: 238;0;0, //Hex:  EE0000
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)0/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) red2{ //R;G;B Dec: 205;0;0, //Hex:  CD0000
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)0/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) red3{ //R;G;B Dec: 139;0;0, //Hex:  8B0000
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)0/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) tomato{ //R;G;B Dec: 255;99;71, //Hex:  FF6347
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)99/255 blue:(CGFloat)71/255 alpha:1];
}
+(UIColor *) tomato1{ //R;G;B Dec: 238;92;66, //Hex:  EE5C42
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)92/255 blue:(CGFloat)66/255 alpha:1];
}
+(UIColor *) tomato2{ //R;G;B Dec: 205;79;57, //Hex:  CD4F39
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)79/255 blue:(CGFloat)57/255 alpha:1];
}
+(UIColor *) tomato3{ //R;G;B Dec: 139;54;38, //Hex:  8B3626
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)54/255 blue:(CGFloat)38/255 alpha:1];
}
+(UIColor *) dustyRose{ //R;G;B Dec: 133;99;99, //Hex:  856363
return [UIColor colorWithRed:(CGFloat)133/255 green:(CGFloat)99/255 blue:(CGFloat)99/255 alpha:1];
}
+(UIColor *) firebrick5{ //R;G;B Dec: 142;35;35, //Hex:  8E2323
return [UIColor colorWithRed:(CGFloat)142/255 green:(CGFloat)35/255 blue:(CGFloat)35/255 alpha:1];
}
+(UIColor *) indianRed5{ //R;G;B Dec: 245;204;176, //Hex:  F5CCB0
return [UIColor colorWithRed:(CGFloat)245/255 green:(CGFloat)204/255 blue:(CGFloat)176/255 alpha:1];
}
+(UIColor *) pink4{ //R;G;B Dec: 188;143;143, //Hex:  BC8F8F
return [UIColor colorWithRed:(CGFloat)188/255 green:(CGFloat)143/255 blue:(CGFloat)143/255 alpha:1];
}
+(UIColor *) salmon4{ //R;G;B Dec: 111;66;66, //Hex:  6F4242
return [UIColor colorWithRed:(CGFloat)111/255 green:(CGFloat)66/255 blue:(CGFloat)66/255 alpha:1];
}
+(UIColor *) scarlet{ //R;G;B Dec: 140;23;23, //Hex:  8C1717
return [UIColor colorWithRed:(CGFloat)140/255 green:(CGFloat)23/255 blue:(CGFloat)23/255 alpha:1];
}
+(UIColor *) spicyPink{ //R;G;B Dec: 255;28;174, //Hex:  FF1CAE
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)28/255 blue:(CGFloat)174/255 alpha:1];
}
+(UIColor *) freeSpeechRed{ //R;G;B Dec: 192;0;0, //Hex:  C00000
return [UIColor colorWithRed:(CGFloat)192/255 green:(CGFloat)0/255 blue:(CGFloat)0/255 alpha:1];
}

#pragma mark Shades of Violet

+(UIColor *) darkOrchid{ //R;G;B Dec: 153;50;204, //Hex:  9932CC
return [UIColor colorWithRed:(CGFloat)153/255 green:(CGFloat)50/255 blue:(CGFloat)204/255 alpha:1];
}
+(UIColor *) darkOrchid1{ //R;G;B Dec: 191;62;255, //Hex:  BF3EFF
return [UIColor colorWithRed:(CGFloat)191/255 green:(CGFloat)62/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) darkOrchid2{ //R;G;B Dec: 178;58;238, //Hex:  B23AEE
return [UIColor colorWithRed:(CGFloat)178/255 green:(CGFloat)58/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) darkOrchid3{ //R;G;B Dec: 154;50;205, //Hex:  9A32CD
return [UIColor colorWithRed:(CGFloat)154/255 green:(CGFloat)50/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) darkOrchid4{ //R;G;B Dec: 104;34;139, //Hex:  68228B
return [UIColor colorWithRed:(CGFloat)104/255 green:(CGFloat)34/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) darkViolet{ //R;G;B Dec: 148;0;211, //Hex:  9400D3
return [UIColor colorWithRed:(CGFloat)148/255 green:(CGFloat)0/255 blue:(CGFloat)211/255 alpha:1];
}
+(UIColor *) lavenderBlush{ //R;G;B Dec: 255;240;245, //Hex:  FFF0F5
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)240/255 blue:(CGFloat)245/255 alpha:1];
}
+(UIColor *) lavenderBlush1{ //R;G;B Dec: 238;224;229, //Hex:  EEE0E5
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)224/255 blue:(CGFloat)229/255 alpha:1];
}
+(UIColor *) lavenderBlush2{ //R;G;B Dec: 205;193;197, //Hex:  CDC1C5
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)193/255 blue:(CGFloat)197/255 alpha:1];
}
+(UIColor *) lavenderBlush3{ //R;G;B Dec: 139;131;134, //Hex:  8B8386
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)131/255 blue:(CGFloat)134/255 alpha:1];
}
+(UIColor *) mediumOrchid{ //R;G;B Dec: 186;85;211, //Hex:  BA55D3
return [UIColor colorWithRed:(CGFloat)186/255 green:(CGFloat)85/255 blue:(CGFloat)211/255 alpha:1];
}
+(UIColor *) mediumOrchid1{ //R;G;B Dec: 224;102;255, //Hex:  E066FF
return [UIColor colorWithRed:(CGFloat)224/255 green:(CGFloat)102/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) mediumOrchid2{ //R;G;B Dec: 209;95;238, //Hex:  D15FEE
return [UIColor colorWithRed:(CGFloat)209/255 green:(CGFloat)95/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) mediumOrchid3{ //R;G;B Dec: 180;82;205, //Hex:  B452CD
return [UIColor colorWithRed:(CGFloat)180/255 green:(CGFloat)82/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) mediumOrchid4{ //R;G;B Dec: 122;55;139, //Hex:  7A378B
return [UIColor colorWithRed:(CGFloat)122/255 green:(CGFloat)55/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) mediumPurple1{ //R;G;B Dec: 171;130;255, //Hex:  AB82FF
return [UIColor colorWithRed:(CGFloat)171/255 green:(CGFloat)130/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) darkOrchid5{ //R;G;B Dec: 153;50;205, //Hex:  9932CD
return [UIColor colorWithRed:(CGFloat)153/255 green:(CGFloat)50/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) mediumPurple2{ //R;G;B Dec: 159;121;238, //Hex:  9F79EE
return [UIColor colorWithRed:(CGFloat)159/255 green:(CGFloat)121/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) mediumPurple3{ //R;G;B Dec: 137;104;205, //Hex:  8968CD
return [UIColor colorWithRed:(CGFloat)137/255 green:(CGFloat)104/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) mediumPurple4{ //R;G;B Dec: 93;71;139, //Hex:  5D478B
return [UIColor colorWithRed:(CGFloat)93/255 green:(CGFloat)71/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) lavender{ //R;G;B Dec: 230;230;250, //Hex:  E6E6FA
return [UIColor colorWithRed:(CGFloat)230/255 green:(CGFloat)230/255 blue:(CGFloat)250/255 alpha:1];
}
+(UIColor *) magenta{ //R;G;B Dec: 255;0;255, //Hex:  FF00FF
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)0/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) magenta1{ //R;G;B Dec: 238;0;238, //Hex:  EE00EE
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)0/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) magenta2{ //R;G;B Dec: 205;0;205, //Hex:  CD00CD
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)0/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) magenta3{ //R;G;B Dec: 139;0;139, //Hex:  8B008B
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)0/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) maroon{ //R;G;B Dec: 176;48;96, //Hex:  B03060
return [UIColor colorWithRed:(CGFloat)176/255 green:(CGFloat)48/255 blue:(CGFloat)96/255 alpha:1];
}
+(UIColor *) maroon1{ //R;G;B Dec: 255;52;179, //Hex:  FF34B3
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)52/255 blue:(CGFloat)179/255 alpha:1];
}
+(UIColor *) maroon2{ //R;G;B Dec: 238;48;167, //Hex:  EE30A7
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)48/255 blue:(CGFloat)167/255 alpha:1];
}
+(UIColor *) maroon3{ //R;G;B Dec: 205;41;144, //Hex:  CD2990
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)41/255 blue:(CGFloat)144/255 alpha:1];
}
+(UIColor *) maroon4{ //R;G;B Dec: 139;28;98, //Hex:  8B1C62
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)28/255 blue:(CGFloat)98/255 alpha:1];
}
+(UIColor *) orchid{ //R;G;B Dec: 219;112;219, //Hex:  DB70DB
return [UIColor colorWithRed:(CGFloat)219/255 green:(CGFloat)112/255 blue:(CGFloat)219/255 alpha:1];
}
+(UIColor *) orchid1{ //R;G;B Dec: 255;131;250, //Hex:  FF83FA
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)131/255 blue:(CGFloat)250/255 alpha:1];
}
+(UIColor *) orchid2{ //R;G;B Dec: 238;122;233, //Hex:  EE7AE9
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)122/255 blue:(CGFloat)233/255 alpha:1];
}
+(UIColor *) orchid3{ //R;G;B Dec: 205;105;201, //Hex:  CD69C9
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)105/255 blue:(CGFloat)201/255 alpha:1];
}
+(UIColor *) orchid4{ //R;G;B Dec: 139;71;137, //Hex:  8B4789
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)71/255 blue:(CGFloat)137/255 alpha:1];
}
+(UIColor *) plum{ //R;G;B Dec: 221;160;221, //Hex:  DDA0DD
return [UIColor colorWithRed:(CGFloat)221/255 green:(CGFloat)160/255 blue:(CGFloat)221/255 alpha:1];
}
+(UIColor *) plum1{ //R;G;B Dec: 255;187;255, //Hex:  FFBBFF
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)187/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) plum2{ //R;G;B Dec: 238;174;238, //Hex:  EEAEEE
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)174/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) plum3{ //R;G;B Dec: 205;150;205, //Hex:  CD96CD
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)150/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) plum4{ //R;G;B Dec: 139;102;139, //Hex:  8B668B
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)102/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) purple{ //R;G;B Dec: 160;32;240, //Hex:  A020F0
return [UIColor colorWithRed:(CGFloat)160/255 green:(CGFloat)32/255 blue:(CGFloat)240/255 alpha:1];
}
+(UIColor *) purple1{ //R;G;B Dec: 155;48;255, //Hex:  9B30FF
return [UIColor colorWithRed:(CGFloat)155/255 green:(CGFloat)48/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) purple2{ //R;G;B Dec: 145;44;238, //Hex:  912CEE
return [UIColor colorWithRed:(CGFloat)145/255 green:(CGFloat)44/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) purple3{ //R;G;B Dec: 125;38;205, //Hex:  7D26CD
return [UIColor colorWithRed:(CGFloat)125/255 green:(CGFloat)38/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) purple4{ //R;G;B Dec: 85;26;139, //Hex:  551A8B
return [UIColor colorWithRed:(CGFloat)85/255 green:(CGFloat)26/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) purple5{ //R;G;B Dec: 128;0;128, //Hex:  800080
return [UIColor colorWithRed:(CGFloat)128/255 green:(CGFloat)0/255 blue:(CGFloat)128/255 alpha:1];
}
+(UIColor *) thistle{ //R;G;B Dec: 216;191;216, //Hex:  D8BFD8
return [UIColor colorWithRed:(CGFloat)216/255 green:(CGFloat)191/255 blue:(CGFloat)216/255 alpha:1];
}
+(UIColor *) thistle1{ //R;G;B Dec: 255;225;255, //Hex:  FFE1FF
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)225/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) thistle2{ //R;G;B Dec: 238;210;238, //Hex:  EED2EE
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)210/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) thistle4{ //R;G;B Dec: 139;123;139, //Hex:  8B7B8B
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)123/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) violet{ //R;G;B Dec: 238;130;238, //Hex:  EE82EE
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)130/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) violetblue{ //R;G;B Dec: 159;95;159, //Hex:  9F5F9F
return [UIColor colorWithRed:(CGFloat)159/255 green:(CGFloat)95/255 blue:(CGFloat)159/255 alpha:1];
}
+(UIColor *) darkPurple{ //R;G;B Dec: 135;31;120, //Hex:  871F78
return [UIColor colorWithRed:(CGFloat)135/255 green:(CGFloat)31/255 blue:(CGFloat)120/255 alpha:1];
}
+(UIColor *) maroon5{ //R;G;B Dec: 245;204;176, //Hex:  F5CCB0
return [UIColor colorWithRed:(CGFloat)245/255 green:(CGFloat)204/255 blue:(CGFloat)176/255 alpha:1];
}
+(UIColor *) maroon6{ //R;G;B Dec: 128;0;0, //Hex:  800000
return [UIColor colorWithRed:(CGFloat)128/255 green:(CGFloat)0/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) mediumVioletRed1{ //R;G;B Dec: 219;112;147, //Hex:  DB7093
return [UIColor colorWithRed:(CGFloat)219/255 green:(CGFloat)112/255 blue:(CGFloat)147/255 alpha:1];
}
+(UIColor *) neonPink{ //R;G;B Dec: 255;110;199, //Hex:  FF6EC7
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)110/255 blue:(CGFloat)199/255 alpha:1];
}
+(UIColor *) plum5{ //R;G;B Dec: 234;173;234, //Hex:  EAADEA
return [UIColor colorWithRed:(CGFloat)234/255 green:(CGFloat)173/255 blue:(CGFloat)234/255 alpha:1];
}
+(UIColor *) turquoise4{ //R;G;B Dec: 173;234;234, //Hex:  ADEAEA
return [UIColor colorWithRed:(CGFloat)173/255 green:(CGFloat)234/255 blue:(CGFloat)234/255 alpha:1];
}
+(UIColor *) violet1{ //R;G;B Dec: 79;47;79, //Hex:  4F2F4F
return [UIColor colorWithRed:(CGFloat)79/255 green:(CGFloat)47/255 blue:(CGFloat)79/255 alpha:1];
}
+(UIColor *) violetRed5{ //R;G;B Dec: 204;50;153, //Hex:  CC3299
return [UIColor colorWithRed:(CGFloat)204/255 green:(CGFloat)50/255 blue:(CGFloat)153/255 alpha:1];
}

#pragma mark Shades of White

+(UIColor *) antiqueWhite{ //R;G;B Dec: 250;235;215, //Hex:  FAEBD7
return [UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)235/255 blue:(CGFloat)215/255 alpha:1];
}
+(UIColor *) antiqueWhite1{ //R;G;B Dec: 255;239;219, //Hex:  FFEFDB
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)239/255 blue:(CGFloat)219/255 alpha:1];
}
+(UIColor *) antiqueWhite2{ //R;G;B Dec: 238;223;204, //Hex:  EEDFCC
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)223/255 blue:(CGFloat)204/255 alpha:1];
}
+(UIColor *) antiqueWhite3{ //R;G;B Dec: 205;192;176, //Hex:  CDC0B0
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)192/255 blue:(CGFloat)176/255 alpha:1];
}
+(UIColor *) antiqueWhite4{ //R;G;B Dec: 139;131;120, //Hex:  8B8378
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)131/255 blue:(CGFloat)120/255 alpha:1];
}
+(UIColor *) floralWhite{ //R;G;B Dec: 255;250;240, //Hex:  FFFAF0
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)250/255 blue:(CGFloat)240/255 alpha:1];
}
+(UIColor *) ghostWhite{ //R;G;B Dec: 248;248;255, //Hex:  F8F8FF
return [UIColor colorWithRed:(CGFloat)248/255 green:(CGFloat)248/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) navajoWhite{ //R;G;B Dec: 255;222;173, //Hex:  FFDEAD
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)222/255 blue:(CGFloat)173/255 alpha:1];
}
+(UIColor *) navajoWhite1{ //R;G;B Dec: 238;207;161, //Hex:  EECFA1
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)207/255 blue:(CGFloat)161/255 alpha:1];
}
+(UIColor *) navajoWhite2{ //R;G;B Dec: 205;179;139, //Hex:  CDB38B
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)179/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) navajoWhite3{ //R;G;B Dec: 139;121;94, //Hex:  8B795E
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)121/255 blue:(CGFloat)94/255 alpha:1];
}
+(UIColor *) oldLace{ //R;G;B Dec: 253;245;230, //Hex:  FDF5E6
return [UIColor colorWithRed:(CGFloat)253/255 green:(CGFloat)245/255 blue:(CGFloat)230/255 alpha:1];
}
+(UIColor *) whiteSmoke{ //R;G;B Dec: 245;245;245, //Hex:  F5F5F5
return [UIColor colorWithRed:(CGFloat)245/255 green:(CGFloat)245/255 blue:(CGFloat)245/255 alpha:1];
}
+(UIColor *) gainsboro{ //R;G;B Dec: 220;220;220, //Hex:  DCDCDC
return [UIColor colorWithRed:(CGFloat)220/255 green:(CGFloat)220/255 blue:(CGFloat)220/255 alpha:1];
}
+(UIColor *) ivory{ //R;G;B Dec: 255;255;240, //Hex:  FFFFF0
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)255/255 blue:(CGFloat)240/255 alpha:1];
}
+(UIColor *) ivory1{ //R;G;B Dec: 238;238;224, //Hex:  EEEEE0
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)238/255 blue:(CGFloat)224/255 alpha:1];
}
+(UIColor *) ivory2{ //R;G;B Dec: 205;205;193, //Hex:  CDCDC1
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)205/255 blue:(CGFloat)193/255 alpha:1];
}
+(UIColor *) ivory3{ //R;G;B Dec: 139;139;131, //Hex:  8B8B83
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)139/255 blue:(CGFloat)131/255 alpha:1];
}
+(UIColor *) linen{ //R;G;B Dec: 250;240;230, //Hex:  FAF0E6
return [UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)240/255 blue:(CGFloat)230/255 alpha:1];
}
+(UIColor *) seashell{ //R;G;B Dec: 255;245;238, //Hex:  FFF5EE
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)245/255 blue:(CGFloat)238/255 alpha:1];
}
+(UIColor *) seashell1{ //R;G;B Dec: 238;229;222, //Hex:  EEE5DE
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)229/255 blue:(CGFloat)222/255 alpha:1];
}
+(UIColor *) seashell2{ //R;G;B Dec: 205;197;191, //Hex:  CDC5BF
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)197/255 blue:(CGFloat)191/255 alpha:1];
}
+(UIColor *) seashell3{ //R;G;B Dec: 139;134;130, //Hex:  8B8682
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)134/255 blue:(CGFloat)130/255 alpha:1];
}
+(UIColor *) snow{ //R;G;B Dec: 255;250;250, //Hex:  FFFAFA
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)250/255 blue:(CGFloat)250/255 alpha:1];
}
+(UIColor *) snow1{ //R;G;B Dec: 238;233;233, //Hex:  EEE9E9
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)233/255 blue:(CGFloat)233/255 alpha:1];
}
+(UIColor *) snow2{ //R;G;B Dec: 205;201;201, //Hex:  CDC9C9
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)201/255 blue:(CGFloat)201/255 alpha:1];
}
+(UIColor *) snow3{ //R;G;B Dec: 139;137;137, //Hex:  8B8989
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)137/255 blue:(CGFloat)137/255 alpha:1];
}
+(UIColor *) wheat{ //R;G;B Dec: 245;222;179, //Hex:  F5DEB3
return [UIColor colorWithRed:(CGFloat)245/255 green:(CGFloat)222/255 blue:(CGFloat)179/255 alpha:1];
}
+(UIColor *) wheat1{ //R;G;B Dec: 255;231;186, //Hex:  FFE7BA
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)231/255 blue:(CGFloat)186/255 alpha:1];
}
+(UIColor *) wheat2{ //R;G;B Dec: 205;186;150, //Hex:  CDBA96
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)186/255 blue:(CGFloat)150/255 alpha:1];
}
+(UIColor *) wheat3{ //R;G;B Dec: 139;126;102, //Hex:  8B7E66
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)126/255 blue:(CGFloat)102/255 alpha:1];
}
+(UIColor *) white{ //R;G;B Dec: 255;255;255, //Hex:  FFFFFF
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)255/255 blue:(CGFloat)255/255 alpha:1];
}
+(UIColor *) quartz{ //R;G;B Dec: 217;217;243, //Hex:  D9D9F3
return [UIColor colorWithRed:(CGFloat)217/255 green:(CGFloat)217/255 blue:(CGFloat)243/255 alpha:1];
}
+(UIColor *) wheat4{ //R;G;B Dec: 216;216;191, //Hex:  D8D8BF
return [UIColor colorWithRed:(CGFloat)216/255 green:(CGFloat)216/255 blue:(CGFloat)191/255 alpha:1];
}

#pragma mark Shades of Yellow

+(UIColor *) blanchedAlmond{ //R;G;B Dec: 255;235;205, //Hex:  FFEBCD
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)235/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) darkGoldenrod{ //R;G;B Dec: 184;134;11, //Hex:  B8860B
return [UIColor colorWithRed:(CGFloat)184/255 green:(CGFloat)134/255 blue:(CGFloat)11/255 alpha:1];
}
+(UIColor *) darkGoldenrod1{ //R;G;B Dec: 255;185;15, //Hex:  FFB90F
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)185/255 blue:(CGFloat)15/255 alpha:1];
}
+(UIColor *) darkGoldenrod2{ //R;G;B Dec: 238;173;14, //Hex:  EEAD0E
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)173/255 blue:(CGFloat)14/255 alpha:1];
}
+(UIColor *) darkGoldenrod3{ //R;G;B Dec: 205;149;12, //Hex:  CD950C
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)149/255 blue:(CGFloat)12/255 alpha:1];
}
+(UIColor *) darkGoldenrod4{ //R;G;B Dec: 139;101;8, //Hex:  8B6508
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)101/255 blue:(CGFloat)8/255 alpha:1];
}
+(UIColor *) lemonChiffon{ //R;G;B Dec: 255;250;205, //Hex:  FFFACD
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)250/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) lemonChiffon1{ //R;G;B Dec: 238;233;191, //Hex:  EEE9BF
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)233/255 blue:(CGFloat)191/255 alpha:1];
}
+(UIColor *) lemonChiffon2{ //R;G;B Dec: 205;201;165, //Hex:  CDC9A5
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)201/255 blue:(CGFloat)165/255 alpha:1];
}
+(UIColor *) lemonChiffon3{ //R;G;B Dec: 139;137;112, //Hex:  8B8970
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)137/255 blue:(CGFloat)112/255 alpha:1];
}
+(UIColor *) lightGoldenrod{ //R;G;B Dec: 238;221;130, //Hex:  EEDD82
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)221/255 blue:(CGFloat)130/255 alpha:1];
}
+(UIColor *) lightGoldenrod1{ //R;G;B Dec: 255;236;139, //Hex:  FFEC8B
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)236/255 blue:(CGFloat)139/255 alpha:1];
}
+(UIColor *) lightGoldenrod2{ //R;G;B Dec: 205;190;112, //Hex:  CDBE70
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)190/255 blue:(CGFloat)112/255 alpha:1];
}
+(UIColor *) lightGoldenrod3{ //R;G;B Dec: 139;129;76, //Hex:  8B814C
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)129/255 blue:(CGFloat)76/255 alpha:1];
}
+(UIColor *) lightYellow{ //R;G;B Dec: 255;255;224, //Hex:  FFFFE0
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)255/255 blue:(CGFloat)224/255 alpha:1];
}
+(UIColor *) lightYellow1{ //R;G;B Dec: 238;238;209, //Hex:  EEEED1
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)238/255 blue:(CGFloat)209/255 alpha:1];
}
+(UIColor *) lightYellow2{ //R;G;B Dec: 205;205;180, //Hex:  CDCDB4
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)205/255 blue:(CGFloat)180/255 alpha:1];
}
+(UIColor *) lightYellow3{ //R;G;B Dec: 139;139;122, //Hex:  8B8B7A
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)139/255 blue:(CGFloat)122/255 alpha:1];
}
+(UIColor *) paleGoldenrod{ //R;G;B Dec: 238;232;170, //Hex:  EEE8AA
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)232/255 blue:(CGFloat)170/255 alpha:1];
}
+(UIColor *) papayaWhip{ //R;G;B Dec: 255;239;213, //Hex:  FFEFD5
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)239/255 blue:(CGFloat)213/255 alpha:1];
}
+(UIColor *) cornsilk{ //R;G;B Dec: 255;248;220, //Hex:  FFF8DC
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)248/255 blue:(CGFloat)220/255 alpha:1];
}
+(UIColor *) cornsilk1{ //R;G;B Dec: 238;232;205, //Hex:  EEE8CD
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)232/255 blue:(CGFloat)205/255 alpha:1];
}
+(UIColor *) cornsilk2{ //R;G;B Dec: 205;200;177, //Hex:  CDC8B1
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)200/255 blue:(CGFloat)177/255 alpha:1];
}
+(UIColor *) cornsilk3{ //R;G;B Dec: 139;136;120, //Hex:  8B8878
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)136/255 blue:(CGFloat)120/255 alpha:1];
}
+(UIColor *) goldenrod{ //R;G;B Dec: 218;165;32, //Hex:  DAA520
return [UIColor colorWithRed:(CGFloat)218/255 green:(CGFloat)165/255 blue:(CGFloat)32/255 alpha:1];
}
+(UIColor *) goldenrod1{ //R;G;B Dec: 255;193;37, //Hex:  FFC125
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)193/255 blue:(CGFloat)37/255 alpha:1];
}
+(UIColor *) goldenrod2{ //R;G;B Dec: 238;180;34, //Hex:  EEB422
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)180/255 blue:(CGFloat)34/255 alpha:1];
}
+(UIColor *) goldenrod3{ //R;G;B Dec: 139;105;20, //Hex:  8B6914
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)105/255 blue:(CGFloat)20/255 alpha:1];
}
+(UIColor *) moccasin{ //R;G;B Dec: 255;228;181, //Hex:  FFE4B5
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)228/255 blue:(CGFloat)181/255 alpha:1];
}
+(UIColor *) yellow{ //R;G;B Dec: 255;255;0, //Hex:  FFFF00
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)255/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) yellow1{ //R;G;B Dec: 205;205;0, //Hex:  CDCD00
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)205/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) yellow2{ //R;G;B Dec: 139;139;0, //Hex:  8B8B00
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)139/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) gold{ //R;G;B Dec: 255;215;0, //Hex:  FFD700
return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)215/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) gold1{ //R;G;B Dec: 238;201;0, //Hex:  EEC900
return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)201/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) gold2{ //R;G;B Dec: 205;173;0, //Hex:  CDAD00
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)173/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) gold3{ //R;G;B Dec: 139;117;0, //Hex:  8B7500
return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)117/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) goldenrod4{ //R;G;B Dec: 219;219;112, //Hex:  DBDB70
return [UIColor colorWithRed:(CGFloat)219/255 green:(CGFloat)219/255 blue:(CGFloat)112/255 alpha:1];
}
+(UIColor *) mediumGoldenrod{ //R;G;B Dec: 234;234;174, //Hex:  EAEAAE
return [UIColor colorWithRed:(CGFloat)234/255 green:(CGFloat)234/255 blue:(CGFloat)174/255 alpha:1];
}
+(UIColor *) yellowGreen1{ //R;G;B Dec: 153;204;50, //Hex:  99CC32
return [UIColor colorWithRed:(CGFloat)153/255 green:(CGFloat)204/255 blue:(CGFloat)50/255 alpha:1];
}

#pragma mark Shades of Metal

+(UIColor *) copper{ //R;G;B Dec: 184;115;51, //Hex:  B87333
return [UIColor colorWithRed:(CGFloat)184/255 green:(CGFloat)115/255 blue:(CGFloat)51/255 alpha:1];
}
+(UIColor *) coolCopper{ //R;G;B Dec: 217;135;25, //Hex:  D98719
return [UIColor colorWithRed:(CGFloat)217/255 green:(CGFloat)135/255 blue:(CGFloat)25/255 alpha:1];
}
+(UIColor *) greenCopper{ //R;G;B Dec: 133;99;99, //Hex:  856363
return [UIColor colorWithRed:(CGFloat)133/255 green:(CGFloat)99/255 blue:(CGFloat)99/255 alpha:1];
}
+(UIColor *) brass{ //R;G;B Dec: 181;166;66, //Hex:  B5A642
return [UIColor colorWithRed:(CGFloat)181/255 green:(CGFloat)166/255 blue:(CGFloat)66/255 alpha:1];
}
+(UIColor *) bronze{ //R;G;B Dec: 140;120;83, //Hex:  8C7853
return [UIColor colorWithRed:(CGFloat)140/255 green:(CGFloat)120/255 blue:(CGFloat)83/255 alpha:1];
}
+(UIColor *) bronzeII{ //R;G;B Dec: 166;125;61, //Hex:  A67D3D
return [UIColor colorWithRed:(CGFloat)166/255 green:(CGFloat)125/255 blue:(CGFloat)61/255 alpha:1];
}
+(UIColor *) brightGold{ //R;G;B Dec: 217;217;25, //Hex:  D9D919
return [UIColor colorWithRed:(CGFloat)217/255 green:(CGFloat)217/255 blue:(CGFloat)25/255 alpha:1];
}
+(UIColor *) oldGold{ //R;G;B Dec: 207;181;59, //Hex:  CFB53B
return [UIColor colorWithRed:(CGFloat)207/255 green:(CGFloat)181/255 blue:(CGFloat)59/255 alpha:1];
}
+(UIColor *) cSSGold{ //R;G;B Dec: 204;153;0, //Hex:  CC9900
return [UIColor colorWithRed:(CGFloat)204/255 green:(CGFloat)153/255 blue:(CGFloat)0/255 alpha:1];
}
+(UIColor *) gold4{ //R;G;B Dec: 205;127;50, //Hex:  CD7F32
return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)127/255 blue:(CGFloat)50/255 alpha:1];
}
+(UIColor *) silver{ //R;G;B Dec: 230;232;250, //Hex:  E6E8FA
return [UIColor colorWithRed:(CGFloat)230/255 green:(CGFloat)232/255 blue:(CGFloat)250/255 alpha:1];
}
+(UIColor *) silver_Grey{ //R;G;B Dec: 192;192;192, //Hex:  C0C0C0
return [UIColor colorWithRed:(CGFloat)192/255 green:(CGFloat)192/255 blue:(CGFloat)192/255 alpha:1];
}
+(UIColor *) lightSteelBlue5{ //R;G;B Dec: 84;84;84, //Hex:  545454
return [UIColor colorWithRed:(CGFloat)84/255 green:(CGFloat)84/255 blue:(CGFloat)84/255 alpha:1];
}
+(UIColor *) steelBlue7{ //R;G;B Dec: 35;107;142, //Hex:  236B8E
return [UIColor colorWithRed:(CGFloat)35/255 green:(CGFloat)107/255 blue:(CGFloat)142/255 alpha:1];
}

#pragma mark Shades of Black and Gray 
+(UIColor *)RGBColorBlackGreyByIndex:(RGBColorBlackGreyName)colorIndex{
	switch (colorIndex) {
		case grey: { //R;G;B Dec: 84;84;84, //Hex:  545454
			return [UIColor colorWithRed:(CGFloat)84/255 green:(CGFloat)84/255 blue:(CGFloat)84/255 alpha:1];
		}
			break;
		case grey_Silver: { //R;G;B Dec: 192;192;192, //Hex:  C0C0C0
			return [UIColor colorWithRed:(CGFloat)192/255 green:(CGFloat)192/255 blue:(CGFloat)192/255 alpha:1];
		}
			break;
		case lightGray: { //R;G;B Dec: 211;211;211, //Hex:  D3D3D3
			return [UIColor colorWithRed:(CGFloat)211/255 green:(CGFloat)211/255 blue:(CGFloat)211/255 alpha:1];
		}
			break;
		case slateGray: { //R;G;B Dec: 112;128;144, //Hex:  708090
			return [UIColor colorWithRed:(CGFloat)112/255 green:(CGFloat)128/255 blue:(CGFloat)144/255 alpha:1];
		}
			break;
		case slateGray1: { //R;G;B Dec: 198;226;255, //Hex:  C6E2FF
			return [UIColor colorWithRed:(CGFloat)198/255 green:(CGFloat)226/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case slateGray3: { //R;G;B Dec: 159;182;205, //Hex:  9FB6CD
			return [UIColor colorWithRed:(CGFloat)159/255 green:(CGFloat)182/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case black: { //R;G;B Dec: 0;0;0, //Hex:  0
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case grey1: { //R;G;B Dec: 38;38;38, //Hex:  262626
			return [UIColor colorWithRed:(CGFloat)38/255 green:(CGFloat)38/255 blue:(CGFloat)38/255 alpha:1];
		}
			break;
		case grey2: { //R;G;B Dec: 105;105;105, //Hex:  696969
			return [UIColor colorWithRed:(CGFloat)105/255 green:(CGFloat)105/255 blue:(CGFloat)105/255 alpha:1];
		}
			break;
		case grey3: { //R;G;B Dec: 186;186;186, //Hex:  BABABA
			return [UIColor colorWithRed:(CGFloat)186/255 green:(CGFloat)186/255 blue:(CGFloat)186/255 alpha:1];
		}
			break;
		case grey4: { //R;G;B Dec: 224;224;224, //Hex:  E0E0E0
			return [UIColor colorWithRed:(CGFloat)224/255 green:(CGFloat)224/255 blue:(CGFloat)224/255 alpha:1];
		}
			break;
		case grey5: { //R;G;B Dec: 240;240;240, //Hex:  F0F0F0
			return [UIColor colorWithRed:(CGFloat)240/255 green:(CGFloat)240/255 blue:(CGFloat)240/255 alpha:1];
		}
			break;
		case grey6: { //R;G;B Dec: 252;252;252, //Hex:  FCFCFC
			return [UIColor colorWithRed:(CGFloat)252/255 green:(CGFloat)252/255 blue:(CGFloat)252/255 alpha:1];
		}
			break;
		case darkSlateGrey: { //R;G;B Dec: 47;79;79, //Hex:  2F4F4F
			return [UIColor colorWithRed:(CGFloat)47/255 green:(CGFloat)79/255 blue:(CGFloat)79/255 alpha:1];
		}
			break;
		case dimGrey: { //R;G;B Dec: 84;84;84, //Hex:  545454
			return [UIColor colorWithRed:(CGFloat)84/255 green:(CGFloat)84/255 blue:(CGFloat)84/255 alpha:1];
		}
			break;
		case lightGrey: { //R;G;B Dec: 219;219;112, //Hex:  DBDB70
			return [UIColor colorWithRed:(CGFloat)219/255 green:(CGFloat)219/255 blue:(CGFloat)112/255 alpha:1];
		}
			break;
		case veryLightGrey: { //R;G;B Dec: 205;205;205, //Hex:  CDCDCD
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)205/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case freeSpeechGrey: { //R;G;B Dec: 99;86;136, //Hex:  635688
			return [UIColor colorWithRed:(CGFloat)99/255 green:(CGFloat)86/255 blue:(CGFloat)136/255 alpha:1];
		}
			break;
	}
	return [UIColor grayColor];
}
	
#pragma mark Shades of Blue
+(UIColor *)RGBColorBlueByIndex:(RGBColorBlueName)colorIndex{
	switch (colorIndex) {
		case aliceBlue: { //R;G;B Dec: 240;248;255, //Hex:  F0F8FF
			return [UIColor colorWithRed:(CGFloat)240/255 green:(CGFloat)248/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case blueViolet: { //R;G;B Dec: 138;43;226, //Hex:  8A2BE2
			return [UIColor colorWithRed:(CGFloat)138/255 green:(CGFloat)43/255 blue:(CGFloat)226/255 alpha:1];
		}
			break;
		case cadetBlue: { //R;G;B Dec: 95;159;159, //Hex:  5F9F9F
			return [UIColor colorWithRed:(CGFloat)95/255 green:(CGFloat)159/255 blue:(CGFloat)159/255 alpha:1];
		}
			break;
		case cadetBlue1: { //R;G;B Dec: 142;229;238, //Hex:  8EE5EE
			return [UIColor colorWithRed:(CGFloat)142/255 green:(CGFloat)229/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case cadetBlue2: { //R;G;B Dec: 122;197;205, //Hex:  7AC5CD
			return [UIColor colorWithRed:(CGFloat)122/255 green:(CGFloat)197/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case cornFlowerBlue1: { //R;G;B Dec: 100;149;237, //Hex:  6495ED
			return [UIColor colorWithRed:(CGFloat)100/255 green:(CGFloat)149/255 blue:(CGFloat)237/255 alpha:1];
		}
			break;
		case darkSlateBlue: { //R;G;B Dec: 72;61;139, //Hex:  483D8B
			return [UIColor colorWithRed:(CGFloat)72/255 green:(CGFloat)61/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case darkTurquoise: { //R;G;B Dec: 0;206;209, //Hex:  00CED1
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)206/255 blue:(CGFloat)209/255 alpha:1];
		}
			break;
		case deepSkyBlue: { //R;G;B Dec: 0;191;255, //Hex:  00BFFF
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)191/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case deepSkyBlue1: { //R;G;B Dec: 0;191;255, //Hex:  00BFFF
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)191/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case deepSkyBlue2: { //R;G;B Dec: 0;154;205, //Hex:  009ACD
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)154/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case deepSkyBlue3: { //R;G;B Dec: 0;104;139, //Hex:  00688B
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)104/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case dodgerBlue: { //R;G;B Dec: 30;144;255, //Hex:  1E90FF
			return [UIColor colorWithRed:(CGFloat)30/255 green:(CGFloat)144/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case dodgerBlue1: { //R;G;B Dec: 28;134;238, //Hex:  1C86EE
			return [UIColor colorWithRed:(CGFloat)28/255 green:(CGFloat)134/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case dodgerBlue2: { //R;G;B Dec: 24;116;205, //Hex:  1874CD
			return [UIColor colorWithRed:(CGFloat)24/255 green:(CGFloat)116/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case dodgerBlue3: { //R;G;B Dec: 16;78;139, //Hex:  104E8B
			return [UIColor colorWithRed:(CGFloat)16/255 green:(CGFloat)78/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case dodgerBlue4: { //R;G;B Dec: 170;187;204, //Hex:  AABBCC
			return [UIColor colorWithRed:(CGFloat)170/255 green:(CGFloat)187/255 blue:(CGFloat)204/255 alpha:1];
		}
			break;
		case lightBlue: { //R;G;B Dec: 173;216;230, //Hex:  ADD8E6
			return [UIColor colorWithRed:(CGFloat)173/255 green:(CGFloat)216/255 blue:(CGFloat)230/255 alpha:1];
		}
			break;
		case lightBlue1: { //R;G;B Dec: 191;239;255, //Hex:  BFEFFF
			return [UIColor colorWithRed:(CGFloat)191/255 green:(CGFloat)239/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case lightBlue3: { //R;G;B Dec: 154;192;205, //Hex:  9AC0CD
			return [UIColor colorWithRed:(CGFloat)154/255 green:(CGFloat)192/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case lightBlue4: { //R;G;B Dec: 104;131;139, //Hex:  68838B
			return [UIColor colorWithRed:(CGFloat)104/255 green:(CGFloat)131/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case lightCyan: { //R;G;B Dec: 224;255;255, //Hex:  E0FFFF
			return [UIColor colorWithRed:(CGFloat)224/255 green:(CGFloat)255/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case lightCyan1: { //R;G;B Dec: 209;238;238, //Hex:  D1EEEE
			return [UIColor colorWithRed:(CGFloat)209/255 green:(CGFloat)238/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case lightCyan2: { //R;G;B Dec: 180;205;205, //Hex:  B4CDCD
			return [UIColor colorWithRed:(CGFloat)180/255 green:(CGFloat)205/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case lightCyan3: { //R;G;B Dec: 122;139;139, //Hex:  7A8B8B
			return [UIColor colorWithRed:(CGFloat)122/255 green:(CGFloat)139/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case lightSkyBlue: { //R;G;B Dec: 135;206;250, //Hex:  87CEFA
			return [UIColor colorWithRed:(CGFloat)135/255 green:(CGFloat)206/255 blue:(CGFloat)250/255 alpha:1];
		}
			break;
		case lightSkyBlue1: { //R;G;B Dec: 176;226;255, //Hex:  B0E2FF
			return [UIColor colorWithRed:(CGFloat)176/255 green:(CGFloat)226/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case lightSkyBlue2: { //R;G;B Dec: 164;211;238, //Hex:  A4D3EE
			return [UIColor colorWithRed:(CGFloat)164/255 green:(CGFloat)211/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case lightSkyBlue3: { //R;G;B Dec: 141;182;205, //Hex:  8DB6CD
			return [UIColor colorWithRed:(CGFloat)141/255 green:(CGFloat)182/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case lightSkyBlue4: { //R;G;B Dec: 96;123;139, //Hex:  607B8B
			return [UIColor colorWithRed:(CGFloat)96/255 green:(CGFloat)123/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case lightSlateBlue: { //R;G;B Dec: 132;112;255, //Hex:  8470FF
			return [UIColor colorWithRed:(CGFloat)132/255 green:(CGFloat)112/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case lightSlateBlue1: { //R;G;B Dec: 153;204;255, //Hex:  99CCFF
			return [UIColor colorWithRed:(CGFloat)153/255 green:(CGFloat)204/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case lightSteelBlue: { //R;G;B Dec: 176;196;222, //Hex:  B0C4DE
			return [UIColor colorWithRed:(CGFloat)176/255 green:(CGFloat)196/255 blue:(CGFloat)222/255 alpha:1];
		}
			break;
		case lightSteelBlue1: { //R;G;B Dec: 202;225;255, //Hex:  CAE1FF
			return [UIColor colorWithRed:(CGFloat)202/255 green:(CGFloat)225/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case lightSteelBlue2: { //R;G;B Dec: 188;210;238, //Hex:  BCD2EE
			return [UIColor colorWithRed:(CGFloat)188/255 green:(CGFloat)210/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case lightSteelBlue3: { //R;G;B Dec: 162;181;205, //Hex:  A2B5CD
			return [UIColor colorWithRed:(CGFloat)162/255 green:(CGFloat)181/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case lightSteelBlue4: { //R;G;B Dec: 110;123;139, //Hex:  6E7B8B
			return [UIColor colorWithRed:(CGFloat)110/255 green:(CGFloat)123/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case aquamarine: { //R;G;B Dec: 112;219;147, //Hex:  70DB93
			return [UIColor colorWithRed:(CGFloat)112/255 green:(CGFloat)219/255 blue:(CGFloat)147/255 alpha:1];
		}
			break;
		case mediumBlue: { //R;G;B Dec: 0;0;205, //Hex:  0000CD
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case mediumSlateBlue: { //R;G;B Dec: 123;104;238, //Hex:  7B68EE
			return [UIColor colorWithRed:(CGFloat)123/255 green:(CGFloat)104/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case mediumTurquoise: { //R;G;B Dec: 72;209;204, //Hex:  48D1CC
			return [UIColor colorWithRed:(CGFloat)72/255 green:(CGFloat)209/255 blue:(CGFloat)204/255 alpha:1];
		}
			break;
		case midnightBlue: { //R;G;B Dec: 25;25;112, //Hex:  191970
			return [UIColor colorWithRed:(CGFloat)25/255 green:(CGFloat)25/255 blue:(CGFloat)112/255 alpha:1];
		}
			break;
		case navyBlue: { //R;G;B Dec: 0;0;128, //Hex:  80
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)128/255 alpha:1];
		}
			break;
		case paleTurquoise: { //R;G;B Dec: 175;238;238, //Hex:  AFEEEE
			return [UIColor colorWithRed:(CGFloat)175/255 green:(CGFloat)238/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case paleTurquoise1: { //R;G;B Dec: 187;255;255, //Hex:  BBFFFF
			return [UIColor colorWithRed:(CGFloat)187/255 green:(CGFloat)255/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case paleTurquoise2: { //R;G;B Dec: 150;205;205, //Hex:  96CDCD
			return [UIColor colorWithRed:(CGFloat)150/255 green:(CGFloat)205/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case paleTurquoise3: { //R;G;B Dec: 102;139;139, //Hex:  668B8B
			return [UIColor colorWithRed:(CGFloat)102/255 green:(CGFloat)139/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case powderBlue: { //R;G;B Dec: 176;224;230, //Hex:  B0E0E6
			return [UIColor colorWithRed:(CGFloat)176/255 green:(CGFloat)224/255 blue:(CGFloat)230/255 alpha:1];
		}
			break;
		case royalBlue: { //R;G;B Dec: 65;105;225, //Hex:  41690
			return [UIColor colorWithRed:(CGFloat)65/255 green:(CGFloat)105/255 blue:(CGFloat)225/255 alpha:1];
		}
			break;
		case royalBlue1: { //R;G;B Dec: 72;118;255, //Hex:  4876FF
			return [UIColor colorWithRed:(CGFloat)72/255 green:(CGFloat)118/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case royalBlue2: { //R;G;B Dec: 58;95;205, //Hex:  3A5FCD
			return [UIColor colorWithRed:(CGFloat)58/255 green:(CGFloat)95/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case royalBlue3: { //R;G;B Dec: 39;64;139, //Hex:  27408B
			return [UIColor colorWithRed:(CGFloat)39/255 green:(CGFloat)64/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case royalBlue4: { //R;G;B Dec: 0;34;102, //Hex:  2266
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)34/255 blue:(CGFloat)102/255 alpha:1];
		}
			break;
		case skyBlue: { //R;G;B Dec: 135;206;235, //Hex:  87CEEB
			return [UIColor colorWithRed:(CGFloat)135/255 green:(CGFloat)206/255 blue:(CGFloat)235/255 alpha:1];
		}
			break;
		case skyBlue1: { //R;G;B Dec: 126;192;238, //Hex:  7EC0EE
			return [UIColor colorWithRed:(CGFloat)126/255 green:(CGFloat)192/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case skyBlue2: { //R;G;B Dec: 108;166;205, //Hex:  6CA6CD
			return [UIColor colorWithRed:(CGFloat)108/255 green:(CGFloat)166/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case skyBlue3: { //R;G;B Dec: 74;112;139, //Hex:  4A708B
			return [UIColor colorWithRed:(CGFloat)74/255 green:(CGFloat)112/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case slateBlue: { //R;G;B Dec: 106;90;205, //Hex:  6A5ACD
			return [UIColor colorWithRed:(CGFloat)106/255 green:(CGFloat)90/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case slateBlue1: { //R;G;B Dec: 131;111;255, //Hex:  836FFF
			return [UIColor colorWithRed:(CGFloat)131/255 green:(CGFloat)111/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case slateBlue2: { //R;G;B Dec: 122;103;238, //Hex:  7A67EE
			return [UIColor colorWithRed:(CGFloat)122/255 green:(CGFloat)103/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case slateBlue3: { //R;G;B Dec: 105;89;205, //Hex:  6959CD
			return [UIColor colorWithRed:(CGFloat)105/255 green:(CGFloat)89/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case slateBlue4: { //R;G;B Dec: 71;60;139, //Hex:  473C8B
			return [UIColor colorWithRed:(CGFloat)71/255 green:(CGFloat)60/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case steelBlue: { //R;G;B Dec: 70;130;180, //Hex:  4682B4
			return [UIColor colorWithRed:(CGFloat)70/255 green:(CGFloat)130/255 blue:(CGFloat)180/255 alpha:1];
		}
			break;
		case steelBlue1: { //R;G;B Dec: 92;172;238, //Hex:  5CACEE
			return [UIColor colorWithRed:(CGFloat)92/255 green:(CGFloat)172/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case steelBlue2: { //R;G;B Dec: 79;148;205, //Hex:  4F94CD
			return [UIColor colorWithRed:(CGFloat)79/255 green:(CGFloat)148/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case steelBlue3: { //R;G;B Dec: 54;100;139, //Hex:  36648B
			return [UIColor colorWithRed:(CGFloat)54/255 green:(CGFloat)100/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case steelBlue4: { //R;G;B Dec: 51;102;153, //Hex:  336699
			return [UIColor colorWithRed:(CGFloat)51/255 green:(CGFloat)102/255 blue:(CGFloat)153/255 alpha:1];
		}
			break;
		case steelBlue5: { //R;G;B Dec: 51;153;204, //Hex:  3399CC
			return [UIColor colorWithRed:(CGFloat)51/255 green:(CGFloat)153/255 blue:(CGFloat)204/255 alpha:1];
		}
			break;
		case steelBlue6: { //R;G;B Dec: 102;153;204, //Hex:  6699CC
			return [UIColor colorWithRed:(CGFloat)102/255 green:(CGFloat)153/255 blue:(CGFloat)204/255 alpha:1];
		}
			break;
		case mediumAquamarine: { //R;G;B Dec: 102;205;170, //Hex:  66CDAA
			return [UIColor colorWithRed:(CGFloat)102/255 green:(CGFloat)205/255 blue:(CGFloat)170/255 alpha:1];
		}
			break;
		case aquamarine1: { //R;G;B Dec: 69;139;116, //Hex:  458B74
			return [UIColor colorWithRed:(CGFloat)69/255 green:(CGFloat)139/255 blue:(CGFloat)116/255 alpha:1];
		}
			break;
		case azure: { //R;G;B Dec: 240;255;255, //Hex:  F0FFFF
			return [UIColor colorWithRed:(CGFloat)240/255 green:(CGFloat)255/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case azure1: { //R;G;B Dec: 224;238;238, //Hex:  E0EEEE
			return [UIColor colorWithRed:(CGFloat)224/255 green:(CGFloat)238/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case azure2: { //R;G;B Dec: 193;205;205, //Hex:  C1CDCD
			return [UIColor colorWithRed:(CGFloat)193/255 green:(CGFloat)205/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case azure3: { //R;G;B Dec: 131;139;139, //Hex:  838B8B
			return [UIColor colorWithRed:(CGFloat)131/255 green:(CGFloat)139/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case blue: { //R;G;B Dec: 0;0;255, //Hex:  0000FF
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case blue1: { //R;G;B Dec: 0;0;238, //Hex:  0000EE
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case blue2: { //R;G;B Dec: 0;0;205, //Hex:  0000CD
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case blue3: { //R;G;B Dec: 0;0;139, //Hex:  00008B
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case aqua: { //R;G;B Dec: 0;255;255, //Hex:  00FFFF
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)255/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case cyan: { //R;G;B Dec: 0;238;238, //Hex:  00EEEE
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)238/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case cyan1: { //R;G;B Dec: 0;205;205, //Hex:  00CDCD
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)205/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case cyan2: { //R;G;B Dec: 0;139;139, //Hex:  008B8B
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)139/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case navy: { //R;G;B Dec: 0;0;128, //Hex:  80
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)128/255 alpha:1];
		}
			break;
		case teal: { //R;G;B Dec: 0;128;128, //Hex:  8080
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)128/255 blue:(CGFloat)128/255 alpha:1];
		}
			break;
		case turquoise: { //R;G;B Dec: 64;224;208, //Hex:  40E0D0
			return [UIColor colorWithRed:(CGFloat)64/255 green:(CGFloat)224/255 blue:(CGFloat)208/255 alpha:1];
		}
			break;
		case turquoise1: { //R;G;B Dec: 0;229;238, //Hex:  00E5EE
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)229/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case turquoise2: { //R;G;B Dec: 0;197;205, //Hex:  00C5CD
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)197/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case turquoise3: { //R;G;B Dec: 0;134;139, //Hex:  00868B
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)134/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case darkSlateGray: { //R;G;B Dec: 47;79;79, //Hex:  2F4F4F
			return [UIColor colorWithRed:(CGFloat)47/255 green:(CGFloat)79/255 blue:(CGFloat)79/255 alpha:1];
		}
			break;
		case darkSlateGray1: { //R;G;B Dec: 141;238;238, //Hex:  8DEEEE
			return [UIColor colorWithRed:(CGFloat)141/255 green:(CGFloat)238/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case darkSlateGray2: { //R;G;B Dec: 121;205;205, //Hex:  79CDCD
			return [UIColor colorWithRed:(CGFloat)121/255 green:(CGFloat)205/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case darkSlateGray3: { //R;G;B Dec: 82;139;139, //Hex:  528B8B
			return [UIColor colorWithRed:(CGFloat)82/255 green:(CGFloat)139/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case darkSlateBlue1: { //R;G;B Dec: 36;24;130, //Hex:  241882
			return [UIColor colorWithRed:(CGFloat)36/255 green:(CGFloat)24/255 blue:(CGFloat)130/255 alpha:1];
		}
			break;
		case darkTurquoise1: { //R;G;B Dec: 112;147;219, //Hex:  7093DB
			return [UIColor colorWithRed:(CGFloat)112/255 green:(CGFloat)147/255 blue:(CGFloat)219/255 alpha:1];
		}
			break;
		case mediumSlateBlue1: { //R;G;B Dec: 127;0;255, //Hex:  7F00FF
			return [UIColor colorWithRed:(CGFloat)127/255 green:(CGFloat)0/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case midnightBlue1: { //R;G;B Dec: 47;47;79, //Hex:  2F2F4F
			return [UIColor colorWithRed:(CGFloat)47/255 green:(CGFloat)47/255 blue:(CGFloat)79/255 alpha:1];
		}
			break;
		case navyBlue1: { //R;G;B Dec: 35;35;142, //Hex:  23238E
			return [UIColor colorWithRed:(CGFloat)35/255 green:(CGFloat)35/255 blue:(CGFloat)142/255 alpha:1];
		}
			break;
		case neonBlue: { //R;G;B Dec: 77;77;255, //Hex:  4D4DFF
			return [UIColor colorWithRed:(CGFloat)77/255 green:(CGFloat)77/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case richBlue: { //R;G;B Dec: 89;89;171, //Hex:  5959AB
			return [UIColor colorWithRed:(CGFloat)89/255 green:(CGFloat)89/255 blue:(CGFloat)171/255 alpha:1];
		}
			break;
		case slateBlue5: { //R;G;B Dec: 0;127;255, //Hex:  007FFF
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)127/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case summerSky: { //R;G;B Dec: 56;176;222, //Hex:  38B0DE
			return [UIColor colorWithRed:(CGFloat)56/255 green:(CGFloat)176/255 blue:(CGFloat)222/255 alpha:1];
		}
			break;
		case irisBlue: { //R;G;B Dec: 3;180;200, //Hex:  03B4C8
			return [UIColor colorWithRed:(CGFloat)3/255 green:(CGFloat)180/255 blue:(CGFloat)200/255 alpha:1];
		}
			break;
		case freeSpeechBlue: { //R;G;B Dec: 65;86;197, //Hex:  4156C5
			return [UIColor colorWithRed:(CGFloat)65/255 green:(CGFloat)86/255 blue:(CGFloat)197/255 alpha:1];
		}
			break;
	}
	return [UIColor blueColor];
}

#pragma mark Shades of Brown
		
+(UIColor *)RGBColorBrownByIndex:(RGBColorBrownName)colorIndex{
	switch (colorIndex) {
		case rosyBrown: { //R;G;B Dec: 188;143;143, //Hex:  BC8F8F
			return [UIColor colorWithRed:(CGFloat)188/255 green:(CGFloat)143/255 blue:(CGFloat)143/255 alpha:1];
		}
			break;
		case rosyBrown1: { //R;G;B Dec: 255;193;193, //Hex:  FFC1C1
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)193/255 blue:(CGFloat)193/255 alpha:1];
		}
			break;
		case rosyBrown2: { //R;G;B Dec: 238;180;180, //Hex:  EEB4B4
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)180/255 blue:(CGFloat)180/255 alpha:1];
		}
			break;
		case rosyBrown3: { //R;G;B Dec: 205;155;155, //Hex:  CD9B9B
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)155/255 blue:(CGFloat)155/255 alpha:1];
		}
			break;
		case rosyBrown4: { //R;G;B Dec: 139;105;105, //Hex:  8B6969
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)105/255 blue:(CGFloat)105/255 alpha:1];
		}
			break;
		case saddleBrown: { //R;G;B Dec: 139;69;19, //Hex:  8B4513
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)69/255 blue:(CGFloat)19/255 alpha:1];
		}
			break;
		case sandyBrown: { //R;G;B Dec: 244;164;96, //Hex:  F4A460
			return [UIColor colorWithRed:(CGFloat)244/255 green:(CGFloat)164/255 blue:(CGFloat)96/255 alpha:1];
		}
			break;
		case beige: { //R;G;B Dec: 245;245;220, //Hex:  F5F5DC
			return [UIColor colorWithRed:(CGFloat)245/255 green:(CGFloat)245/255 blue:(CGFloat)220/255 alpha:1];
		}
			break;
		case brown: { //R;G;B Dec: 165;42;42, //Hex:  A52A2A
			return [UIColor colorWithRed:(CGFloat)165/255 green:(CGFloat)42/255 blue:(CGFloat)42/255 alpha:1];
		}
			break;
		case brown1: { //R;G;B Dec: 255;64;64, //Hex:  FF4040
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)64/255 blue:(CGFloat)64/255 alpha:1];
		}
			break;
		case brown2: { //R;G;B Dec: 238;59;59, //Hex:  EE3B3B
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)59/255 blue:(CGFloat)59/255 alpha:1];
		}
			break;
		case brown3: { //R;G;B Dec: 205;51;51, //Hex:  CD3333
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)51/255 blue:(CGFloat)51/255 alpha:1];
		}
			break;
		case brown4: { //R;G;B Dec: 139;35;35, //Hex:  8B2323
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)35/255 blue:(CGFloat)35/255 alpha:1];
		}
			break;
		case darkBrown: { //R;G;B Dec: 92;64;51, //Hex:  5C4033
			return [UIColor colorWithRed:(CGFloat)92/255 green:(CGFloat)64/255 blue:(CGFloat)51/255 alpha:1];
		}
			break;
		case burlywood: { //R;G;B Dec: 222;184;135, //Hex:  DEB887
			return [UIColor colorWithRed:(CGFloat)222/255 green:(CGFloat)184/255 blue:(CGFloat)135/255 alpha:1];
		}
			break;
		case burlywood1: { //R;G;B Dec: 255;211;155, //Hex:  FFD39B
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)211/255 blue:(CGFloat)155/255 alpha:1];
		}
			break;
		case burlywood2: { //R;G;B Dec: 139;115;85, //Hex:  8B7355
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)115/255 blue:(CGFloat)85/255 alpha:1];
		}
			break;
		case bakersChocolate: { //R;G;B Dec: 92;51;23, //Hex:  5C3317
			return [UIColor colorWithRed:(CGFloat)92/255 green:(CGFloat)51/255 blue:(CGFloat)23/255 alpha:1];
		}
			break;
		case chocolate: { //R;G;B Dec: 210;105;30, //Hex:  D2691E
			return [UIColor colorWithRed:(CGFloat)210/255 green:(CGFloat)105/255 blue:(CGFloat)30/255 alpha:1];
		}
			break;
		case chocolate1: { //R;G;B Dec: 255;127;36, //Hex:  FF7F24
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)127/255 blue:(CGFloat)36/255 alpha:1];
		}
			break;
		case chocolate2: { //R;G;B Dec: 238;118;33, //Hex:  EE7621
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)118/255 blue:(CGFloat)33/255 alpha:1];
		}
			break;
		case chocolate3: { //R;G;B Dec: 139;69;19, //Hex:  8B4513
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)69/255 blue:(CGFloat)19/255 alpha:1];
		}
			break;
		case peru: { //R;G;B Dec: 205;133;63, //Hex:  CD853F
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)133/255 blue:(CGFloat)63/255 alpha:1];
		}
			break;
		case tan_: { //R;G;B Dec: 210;180;140, //Hex:  D2B48C
			return [UIColor colorWithRed:(CGFloat)210/255 green:(CGFloat)180/255 blue:(CGFloat)140/255 alpha:1];
		}
			break;
		case tan1: { //R;G;B Dec: 255;165;79, //Hex:  FFA54F
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)165/255 blue:(CGFloat)79/255 alpha:1];
		}
			break;
		case tan2: { //R;G;B Dec: 205;133;63, //Hex:  CD853F
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)133/255 blue:(CGFloat)63/255 alpha:1];
		}
			break;
		case darkTan: { //R;G;B Dec: 151;105;79, //Hex:  97694F
			return [UIColor colorWithRed:(CGFloat)151/255 green:(CGFloat)105/255 blue:(CGFloat)79/255 alpha:1];
		}
			break;
		case darkWood: { //R;G;B Dec: 133;94;66, //Hex:  8.55E+44
			return [UIColor colorWithRed:(CGFloat)133/255 green:(CGFloat)94/255 blue:(CGFloat)66/255 alpha:1];
		}
			break;
		case lightWood: { //R;G;B Dec: 133;99;99, //Hex:  856363
			return [UIColor colorWithRed:(CGFloat)133/255 green:(CGFloat)99/255 blue:(CGFloat)99/255 alpha:1];
		}
			break;
		case mediumWood: { //R;G;B Dec: 166;128;100, //Hex:  A68064
			return [UIColor colorWithRed:(CGFloat)166/255 green:(CGFloat)128/255 blue:(CGFloat)100/255 alpha:1];
		}
			break;
		case newTan: { //R;G;B Dec: 235;199;158, //Hex:  EBC79E
			return [UIColor colorWithRed:(CGFloat)235/255 green:(CGFloat)199/255 blue:(CGFloat)158/255 alpha:1];
		}
			break;
		case sienna5: { //R;G;B Dec: 142;107;35, //Hex:  8E6B23
			return [UIColor colorWithRed:(CGFloat)142/255 green:(CGFloat)107/255 blue:(CGFloat)35/255 alpha:1];
		}
			break;
		case tan3: { //R;G;B Dec: 219;147;112, //Hex:  DB9370
			return [UIColor colorWithRed:(CGFloat)219/255 green:(CGFloat)147/255 blue:(CGFloat)112/255 alpha:1];
		}
			break;
		case veryDarkBrown: { //R;G;B Dec: 92;64;51, //Hex:  5C4033
			return [UIColor colorWithRed:(CGFloat)92/255 green:(CGFloat)64/255 blue:(CGFloat)51/255 alpha:1];
		}
			break;
	}
	return [UIColor brownColor];
}

#pragma mark Shades of Green
		
+(UIColor *)RGBColorGreenByIndex:(RGBColorGreenName)colorIndex{
	switch (colorIndex) {
		case darkGreen: { //R;G;B Dec: 47;79;47, //Hex:  2F4F2F
			return [UIColor colorWithRed:(CGFloat)47/255 green:(CGFloat)79/255 blue:(CGFloat)47/255 alpha:1];
		}
			break;
		case darkGreen1: { //R;G;B Dec: 0;100;0, //Hex:  6400
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)100/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case darkgreencopper: { //R;G;B Dec: 74;118;110, //Hex:  4A766E
			return [UIColor colorWithRed:(CGFloat)74/255 green:(CGFloat)118/255 blue:(CGFloat)110/255 alpha:1];
		}
			break;
		case darkKhaki: { //R;G;B Dec: 189;183;107, //Hex:  BDB76B
			return [UIColor colorWithRed:(CGFloat)189/255 green:(CGFloat)183/255 blue:(CGFloat)107/255 alpha:1];
		}
			break;
		case darkOliveGreen: { //R;G;B Dec: 85;107;47, //Hex:  556B2F
			return [UIColor colorWithRed:(CGFloat)85/255 green:(CGFloat)107/255 blue:(CGFloat)47/255 alpha:1];
		}
			break;
		case darkOliveGreen1: { //R;G;B Dec: 202;255;112, //Hex:  CAFF70
			return [UIColor colorWithRed:(CGFloat)202/255 green:(CGFloat)255/255 blue:(CGFloat)112/255 alpha:1];
		}
			break;
		case darkOliveGreen2: { //R;G;B Dec: 188;238;104, //Hex:  BCEE68
			return [UIColor colorWithRed:(CGFloat)188/255 green:(CGFloat)238/255 blue:(CGFloat)104/255 alpha:1];
		}
			break;
		case darkOliveGreen3: { //R;G;B Dec: 162;205;90, //Hex:  A2CD5A
			return [UIColor colorWithRed:(CGFloat)162/255 green:(CGFloat)205/255 blue:(CGFloat)90/255 alpha:1];
		}
			break;
		case darkOliveGreen4: { //R;G;B Dec: 110;139;61, //Hex:  6E8B3D
			return [UIColor colorWithRed:(CGFloat)110/255 green:(CGFloat)139/255 blue:(CGFloat)61/255 alpha:1];
		}
			break;
		case olive: { //R;G;B Dec: 128;128;0, //Hex:  808000
			return [UIColor colorWithRed:(CGFloat)128/255 green:(CGFloat)128/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case darkSeaGreen: { //R;G;B Dec: 143;188;143, //Hex:  8FBC8F
			return [UIColor colorWithRed:(CGFloat)143/255 green:(CGFloat)188/255 blue:(CGFloat)143/255 alpha:1];
		}
			break;
		case darkSeaGreen1: { //R;G;B Dec: 193;255;193, //Hex:  C1FFC1
			return [UIColor colorWithRed:(CGFloat)193/255 green:(CGFloat)255/255 blue:(CGFloat)193/255 alpha:1];
		}
			break;
		case darkSeaGreen2: { //R;G;B Dec: 180;238;180, //Hex:  B4EEB4
			return [UIColor colorWithRed:(CGFloat)180/255 green:(CGFloat)238/255 blue:(CGFloat)180/255 alpha:1];
		}
			break;
		case darkSeaGreen3: { //R;G;B Dec: 105;139;105, //Hex:  698B69
			return [UIColor colorWithRed:(CGFloat)105/255 green:(CGFloat)139/255 blue:(CGFloat)105/255 alpha:1];
		}
			break;
		case forestGreen: { //R;G;B Dec: 34;139;34, //Hex:  228B22
			return [UIColor colorWithRed:(CGFloat)34/255 green:(CGFloat)139/255 blue:(CGFloat)34/255 alpha:1];
		}
			break;
		case greenYellow: { //R;G;B Dec: 173;255;47, //Hex:  ADFF2F
			return [UIColor colorWithRed:(CGFloat)173/255 green:(CGFloat)255/255 blue:(CGFloat)47/255 alpha:1];
		}
			break;
		case lawnGreen: { //R;G;B Dec: 124;252;0, //Hex:  7CFC00
			return [UIColor colorWithRed:(CGFloat)124/255 green:(CGFloat)252/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case lightSeaGreen: { //R;G;B Dec: 32;178;170, //Hex:  20B2AA
			return [UIColor colorWithRed:(CGFloat)32/255 green:(CGFloat)178/255 blue:(CGFloat)170/255 alpha:1];
		}
			break;
		case limeGreen: { //R;G;B Dec: 50;205;50, //Hex:  32CD32
			return [UIColor colorWithRed:(CGFloat)50/255 green:(CGFloat)205/255 blue:(CGFloat)50/255 alpha:1];
		}
			break;
		case mediumSeaGreen: { //R;G;B Dec: 60;179;113, //Hex:  3CB371
			return [UIColor colorWithRed:(CGFloat)60/255 green:(CGFloat)179/255 blue:(CGFloat)113/255 alpha:1];
		}
			break;
		case mediumSpringGreen: { //R;G;B Dec: 0;250;154, //Hex:  00FA9A
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)250/255 blue:(CGFloat)154/255 alpha:1];
		}
			break;
		case oliveDrab: { //R;G;B Dec: 107;142;35, //Hex:  6B8E23
			return [UIColor colorWithRed:(CGFloat)107/255 green:(CGFloat)142/255 blue:(CGFloat)35/255 alpha:1];
		}
			break;
		case oliveDrab1: { //R;G;B Dec: 192;255;62, //Hex:  C0FF3E
			return [UIColor colorWithRed:(CGFloat)192/255 green:(CGFloat)255/255 blue:(CGFloat)62/255 alpha:1];
		}
			break;
		case oliveDrab2: { //R;G;B Dec: 179;238;58, //Hex:  B3EE3A
			return [UIColor colorWithRed:(CGFloat)179/255 green:(CGFloat)238/255 blue:(CGFloat)58/255 alpha:1];
		}
			break;
		case oliveDrab3: { //R;G;B Dec: 154;205;50, //Hex:  9ACD32
			return [UIColor colorWithRed:(CGFloat)154/255 green:(CGFloat)205/255 blue:(CGFloat)50/255 alpha:1];
		}
			break;
		case oliveDrab4: { //R;G;B Dec: 105;139;34, //Hex:  698B22
			return [UIColor colorWithRed:(CGFloat)105/255 green:(CGFloat)139/255 blue:(CGFloat)34/255 alpha:1];
		}
			break;
		case paleGreen: { //R;G;B Dec: 152;251;152, //Hex:  98FB98
			return [UIColor colorWithRed:(CGFloat)152/255 green:(CGFloat)251/255 blue:(CGFloat)152/255 alpha:1];
		}
			break;
		case paleGreen1: { //R;G;B Dec: 124;205;124, //Hex:  7CCD7C
			return [UIColor colorWithRed:(CGFloat)124/255 green:(CGFloat)205/255 blue:(CGFloat)124/255 alpha:1];
		}
			break;
		case paleGreen2: { //R;G;B Dec: 84;139;84, //Hex:  548B54
			return [UIColor colorWithRed:(CGFloat)84/255 green:(CGFloat)139/255 blue:(CGFloat)84/255 alpha:1];
		}
			break;
		case seaGreen: { //R;G;B Dec: 46;139;87, //Hex:  2E8B57
			return [UIColor colorWithRed:(CGFloat)46/255 green:(CGFloat)139/255 blue:(CGFloat)87/255 alpha:1];
		}
			break;
		case seaGreen1: { //R;G;B Dec: 84;255;159, //Hex:  54FF9F
			return [UIColor colorWithRed:(CGFloat)84/255 green:(CGFloat)255/255 blue:(CGFloat)159/255 alpha:1];
		}
			break;
		case seaGreen2: { //R;G;B Dec: 67;205;128, //Hex:  43CD80
			return [UIColor colorWithRed:(CGFloat)67/255 green:(CGFloat)205/255 blue:(CGFloat)128/255 alpha:1];
		}
			break;
		case springGreen: { //R;G;B Dec: 0;255;127, //Hex:  00FF7F
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)255/255 blue:(CGFloat)127/255 alpha:1];
		}
			break;
		case springGreen1: { //R;G;B Dec: 0;139;69, //Hex:  008B45
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)139/255 blue:(CGFloat)69/255 alpha:1];
		}
			break;
		case yellowGreen: { //R;G;B Dec: 154;205;50, //Hex:  9ACD32
			return [UIColor colorWithRed:(CGFloat)154/255 green:(CGFloat)205/255 blue:(CGFloat)50/255 alpha:1];
		}
			break;
		case chartreuse: { //R;G;B Dec: 127;255;0, //Hex:  7FFF00
			return [UIColor colorWithRed:(CGFloat)127/255 green:(CGFloat)255/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case chartreuse1: { //R;G;B Dec: 102;205;0, //Hex:  66CD00
			return [UIColor colorWithRed:(CGFloat)102/255 green:(CGFloat)205/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case chartreuse2: { //R;G;B Dec: 69;139;0, //Hex:  458B00
			return [UIColor colorWithRed:(CGFloat)69/255 green:(CGFloat)139/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case green: { //R;G;B Dec: 0;128;0, //Hex:  8000
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)128/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case green1: { //R;G;B Dec: 0;139;0, //Hex:  008B00
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)139/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case khaki: { //R;G;B Dec: 240;230;140, //Hex:  F0E68C
			return [UIColor colorWithRed:(CGFloat)240/255 green:(CGFloat)230/255 blue:(CGFloat)140/255 alpha:1];
		}
			break;
		case khaki1: { //R;G;B Dec: 205;198;115, //Hex:  CDC673
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)198/255 blue:(CGFloat)115/255 alpha:1];
		}
			break;
		case khaki2: { //R;G;B Dec: 139;134;78, //Hex:  8B864E
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)134/255 blue:(CGFloat)78/255 alpha:1];
		}
			break;
		case darkOliveGreen5: { //R;G;B Dec: 79;79;47, //Hex:  4F4F2F
			return [UIColor colorWithRed:(CGFloat)79/255 green:(CGFloat)79/255 blue:(CGFloat)47/255 alpha:1];
		}
			break;
		case greenYellow1: { //R;G;B Dec: 209;146;117, //Hex:  D19275
			return [UIColor colorWithRed:(CGFloat)209/255 green:(CGFloat)146/255 blue:(CGFloat)117/255 alpha:1];
		}
			break;
		case hunterGreen: { //R;G;B Dec: 142;35;35, //Hex:  8E2323
			return [UIColor colorWithRed:(CGFloat)142/255 green:(CGFloat)35/255 blue:(CGFloat)35/255 alpha:1];
		}
			break;
		case forestGreen1: { //R;G;B Dec: 35;142;35, //Hex:  2.38E+25
			return [UIColor colorWithRed:(CGFloat)35/255 green:(CGFloat)142/255 blue:(CGFloat)35/255 alpha:1];
		}
			break;
		case limeGreen1: { //R;G;B Dec: 209;146;117, //Hex:  D19275
			return [UIColor colorWithRed:(CGFloat)209/255 green:(CGFloat)146/255 blue:(CGFloat)117/255 alpha:1];
		}
			break;
		case mediumForestGreen: { //R;G;B Dec: 219;219;112, //Hex:  DBDB70
			return [UIColor colorWithRed:(CGFloat)219/255 green:(CGFloat)219/255 blue:(CGFloat)112/255 alpha:1];
		}
			break;
		case mediumSeaGreen1: { //R;G;B Dec: 66;111;66, //Hex:  426F42
			return [UIColor colorWithRed:(CGFloat)66/255 green:(CGFloat)111/255 blue:(CGFloat)66/255 alpha:1];
		}
			break;
		case mediumSpringGreen1: { //R;G;B Dec: 127;255;0, //Hex:  7FFF00
			return [UIColor colorWithRed:(CGFloat)127/255 green:(CGFloat)255/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case paleGreen3: { //R;G;B Dec: 143;188;143, //Hex:  8FBC8F
			return [UIColor colorWithRed:(CGFloat)143/255 green:(CGFloat)188/255 blue:(CGFloat)143/255 alpha:1];
		}
			break;
		case seaGreen3: { //R;G;B Dec: 35;142;104, //Hex:  2.38E+70
			return [UIColor colorWithRed:(CGFloat)35/255 green:(CGFloat)142/255 blue:(CGFloat)104/255 alpha:1];
		}
			break;
		case springGreen2: { //R;G;B Dec: 0;255;127, //Hex:  00FF7F
			return [UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)255/255 blue:(CGFloat)127/255 alpha:1];
		}
			break;
		case freeSpeechGreen: { //R;G;B Dec: 9;249;17, //Hex:  09F911
			return [UIColor colorWithRed:(CGFloat)9/255 green:(CGFloat)249/255 blue:(CGFloat)17/255 alpha:1];
		}
			break;
	}
	return [UIColor greenColor];
}

#pragma mark Shades of Orange
		
+(UIColor *)RGBColorOrangeByIndex:(RGBColorOrangeName)colorIndex{
	switch (colorIndex) {
		case darkOrange: { //R;G;B Dec: 255;140;0, //Hex:  FF8C00
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)140/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case darkOrange1: { //R;G;B Dec: 205;102;0, //Hex:  CD6600
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)102/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case darkOrange2: { //R;G;B Dec: 139;69;0, //Hex:  8B4500
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)69/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case darkSalmon: { //R;G;B Dec: 233;150;122, //Hex:  E9967A
			return [UIColor colorWithRed:(CGFloat)233/255 green:(CGFloat)150/255 blue:(CGFloat)122/255 alpha:1];
		}
			break;
		case lightCoral: { //R;G;B Dec: 240;128;128, //Hex:  F08080
			return [UIColor colorWithRed:(CGFloat)240/255 green:(CGFloat)128/255 blue:(CGFloat)128/255 alpha:1];
		}
			break;
		case lightSalmon: { //R;G;B Dec: 255;160;122, //Hex:  FFA07A
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)160/255 blue:(CGFloat)122/255 alpha:1];
		}
			break;
		case lightSalmon1: { //R;G;B Dec: 139;87;66, //Hex:  8B5742
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)87/255 blue:(CGFloat)66/255 alpha:1];
		}
			break;
		case peachPuff: { //R;G;B Dec: 255;218;185, //Hex:  FFDAB9
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)218/255 blue:(CGFloat)185/255 alpha:1];
		}
			break;
		case peachPuff1: { //R;G;B Dec: 238;203;173, //Hex:  EECBAD
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)203/255 blue:(CGFloat)173/255 alpha:1];
		}
			break;
		case peachPuff2: { //R;G;B Dec: 205;175;149, //Hex:  CDAF95
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)175/255 blue:(CGFloat)149/255 alpha:1];
		}
			break;
		case peachPuff3: { //R;G;B Dec: 139;119;101, //Hex:  8B7765
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)119/255 blue:(CGFloat)101/255 alpha:1];
		}
			break;
		case bisque: { //R;G;B Dec: 255;228;196, //Hex:  FFE4C4
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)228/255 blue:(CGFloat)196/255 alpha:1];
		}
			break;
		case bisque1: { //R;G;B Dec: 238;213;183, //Hex:  EED5B7
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)213/255 blue:(CGFloat)183/255 alpha:1];
		}
			break;
		case bisque2: { //R;G;B Dec: 205;183;158, //Hex:  CDB79E
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)183/255 blue:(CGFloat)158/255 alpha:1];
		}
			break;
		case bisque3: { //R;G;B Dec: 139;125;107, //Hex:  8B7D6B
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)125/255 blue:(CGFloat)107/255 alpha:1];
		}
			break;
		case coral: { //R;G;B Dec: 255;127;0, //Hex:  FF7F00
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)127/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case coral1: { //R;G;B Dec: 238;106;80, //Hex:  EE6A50
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)106/255 blue:(CGFloat)80/255 alpha:1];
		}
			break;
		case coral2: { //R;G;B Dec: 205;91;69, //Hex:  CD5B45
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)91/255 blue:(CGFloat)69/255 alpha:1];
		}
			break;
		case coral3: { //R;G;B Dec: 139;62;47, //Hex:  8B3E2F
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)62/255 blue:(CGFloat)47/255 alpha:1];
		}
			break;
		case honeydew: { //R;G;B Dec: 240;255;240, //Hex:  F0FFF0
			return [UIColor colorWithRed:(CGFloat)240/255 green:(CGFloat)255/255 blue:(CGFloat)240/255 alpha:1];
		}
			break;
		case honeydew1: { //R;G;B Dec: 224;238;224, //Hex:  E0EEE0
			return [UIColor colorWithRed:(CGFloat)224/255 green:(CGFloat)238/255 blue:(CGFloat)224/255 alpha:1];
		}
			break;
		case honeydew2: { //R;G;B Dec: 193;205;193, //Hex:  C1CDC1
			return [UIColor colorWithRed:(CGFloat)193/255 green:(CGFloat)205/255 blue:(CGFloat)193/255 alpha:1];
		}
			break;
		case honeydew3: { //R;G;B Dec: 131;139;131, //Hex:  838B83
			return [UIColor colorWithRed:(CGFloat)131/255 green:(CGFloat)139/255 blue:(CGFloat)131/255 alpha:1];
		}
			break;
		case orange: { //R;G;B Dec: 255;165;0, //Hex:  FFA500
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)165/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case orange1: { //R;G;B Dec: 238;154;0, //Hex:  EE9A00
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)154/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case orange2: { //R;G;B Dec: 205;133;0, //Hex:  CD8500
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)133/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case orange3: { //R;G;B Dec: 139;90;0, //Hex:  8B5A00
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)90/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case salmon: { //R;G;B Dec: 250;128;114, //Hex:  FA8072
			return [UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)128/255 blue:(CGFloat)114/255 alpha:1];
		}
			break;
		case salmon1: { //R;G;B Dec: 255;140;105, //Hex:  FF8C69
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)140/255 blue:(CGFloat)105/255 alpha:1];
		}
			break;
		case salmon2: { //R;G;B Dec: 205;112;84, //Hex:  CD7054
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)112/255 blue:(CGFloat)84/255 alpha:1];
		}
			break;
		case salmon3: { //R;G;B Dec: 139;76;57, //Hex:  8B4C39
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)76/255 blue:(CGFloat)57/255 alpha:1];
		}
			break;
		case sienna: { //R;G;B Dec: 160;82;45, //Hex:  A0522D
			return [UIColor colorWithRed:(CGFloat)160/255 green:(CGFloat)82/255 blue:(CGFloat)45/255 alpha:1];
		}
			break;
		case sienna1: { //R;G;B Dec: 255;130;71, //Hex:  FF8247
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)130/255 blue:(CGFloat)71/255 alpha:1];
		}
			break;
		case sienna2: { //R;G;B Dec: 238;121;66, //Hex:  EE7942
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)121/255 blue:(CGFloat)66/255 alpha:1];
		}
			break;
		case sienna3: { //R;G;B Dec: 205;104;57, //Hex:  CD6839
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)104/255 blue:(CGFloat)57/255 alpha:1];
		}
			break;
		case sienna4: { //R;G;B Dec: 139;71;38, //Hex:  8B4726
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)71/255 blue:(CGFloat)38/255 alpha:1];
		}
			break;
		case mandarianOrange: { //R;G;B Dec: 142;35;35, //Hex:  8E2323
			return [UIColor colorWithRed:(CGFloat)142/255 green:(CGFloat)35/255 blue:(CGFloat)35/255 alpha:1];
		}
			break;
		case orange4: { //R;G;B Dec: 255;127;0, //Hex:  FF7F00
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)127/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case orangeRed4: { //R;G;B Dec: 255;36;0, //Hex:  FF2400
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)36/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
	}
	return [UIColor orangeColor];
}

#pragma mark Shades of Red
		
+(UIColor *)RGBColorRedByIndex:(RGBColorRedName)colorIndex{
	switch (colorIndex) {
		case deepPink: { //R;G;B Dec: 255;20;147, //Hex:  FF1493
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)20/255 blue:(CGFloat)147/255 alpha:1];
		}
			break;
		case deepPink1: { //R;G;B Dec: 238;18;137, //Hex:  EE1289
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)18/255 blue:(CGFloat)137/255 alpha:1];
		}
			break;
		case deepPink2: { //R;G;B Dec: 205;16;118, //Hex:  CD1076
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)16/255 blue:(CGFloat)118/255 alpha:1];
		}
			break;
		case deepPink3: { //R;G;B Dec: 139;10;80, //Hex:  8B0A50
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)10/255 blue:(CGFloat)80/255 alpha:1];
		}
			break;
		case hotPink: { //R;G;B Dec: 255;105;180, //Hex:  FF69B4
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)105/255 blue:(CGFloat)180/255 alpha:1];
		}
			break;
		case hotPink1: { //R;G;B Dec: 238;106;167, //Hex:  EE6AA7
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)106/255 blue:(CGFloat)167/255 alpha:1];
		}
			break;
		case hotPink2: { //R;G;B Dec: 205;96;144, //Hex:  CD6090
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)96/255 blue:(CGFloat)144/255 alpha:1];
		}
			break;
		case hotPink3: { //R;G;B Dec: 139;58;98, //Hex:  8B3A62
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)58/255 blue:(CGFloat)98/255 alpha:1];
		}
			break;
		case indianRed: { //R;G;B Dec: 205;92;92, //Hex:  CD5C5C
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)92/255 blue:(CGFloat)92/255 alpha:1];
		}
			break;
		case indianRed1: { //R;G;B Dec: 255;106;106, //Hex:  FF6A6A
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)106/255 blue:(CGFloat)106/255 alpha:1];
		}
			break;
		case indianRed2: { //R;G;B Dec: 238;99;99, //Hex:  EE6363
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)99/255 blue:(CGFloat)99/255 alpha:1];
		}
			break;
		case indianRed3: { //R;G;B Dec: 205;85;85, //Hex:  CD5555
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)85/255 blue:(CGFloat)85/255 alpha:1];
		}
			break;
		case indianRed4: { //R;G;B Dec: 139;58;58, //Hex:  8B3A3A
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)58/255 blue:(CGFloat)58/255 alpha:1];
		}
			break;
		case lightPink: { //R;G;B Dec: 255;182;193, //Hex:  FFB6C1
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)182/255 blue:(CGFloat)193/255 alpha:1];
		}
			break;
		case lightPink1: { //R;G;B Dec: 238;162;173, //Hex:  EEA2AD
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)162/255 blue:(CGFloat)173/255 alpha:1];
		}
			break;
		case lightPink2: { //R;G;B Dec: 205;140;149, //Hex:  CD8C95
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)140/255 blue:(CGFloat)149/255 alpha:1];
		}
			break;
		case lightPink3: { //R;G;B Dec: 139;95;101, //Hex:  8B5F65
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)95/255 blue:(CGFloat)101/255 alpha:1];
		}
			break;
		case mediumVioletRed: { //R;G;B Dec: 199;21;133, //Hex:  C71585
			return [UIColor colorWithRed:(CGFloat)199/255 green:(CGFloat)21/255 blue:(CGFloat)133/255 alpha:1];
		}
			break;
		case mistyRose: { //R;G;B Dec: 255;228;225, //Hex:  FFE4E1
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)228/255 blue:(CGFloat)225/255 alpha:1];
		}
			break;
		case mistyRose1: { //R;G;B Dec: 238;213;210, //Hex:  EED5D2
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)213/255 blue:(CGFloat)210/255 alpha:1];
		}
			break;
		case mistyRose2: { //R;G;B Dec: 205;183;181, //Hex:  CDB7B5
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)183/255 blue:(CGFloat)181/255 alpha:1];
		}
			break;
		case mistyRose3: { //R;G;B Dec: 139;125;123, //Hex:  8B7D7B
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)125/255 blue:(CGFloat)123/255 alpha:1];
		}
			break;
		case orangeRed: { //R;G;B Dec: 255;69;0, //Hex:  FF4500
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)69/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case orangeRed1: { //R;G;B Dec: 238;64;0, //Hex:  EE4000
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)64/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case orangeRed2: { //R;G;B Dec: 205;55;0, //Hex:  CD3700
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)55/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case orangeRed3: { //R;G;B Dec: 139;37;0, //Hex:  8B2500
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)37/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case paleVioletRed: { //R;G;B Dec: 219;112;147, //Hex:  DB7093
			return [UIColor colorWithRed:(CGFloat)219/255 green:(CGFloat)112/255 blue:(CGFloat)147/255 alpha:1];
		}
			break;
		case paleVioletRed1: { //R;G;B Dec: 255;130;171, //Hex:  FF82AB
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)130/255 blue:(CGFloat)171/255 alpha:1];
		}
			break;
		case paleVioletRed2: { //R;G;B Dec: 238;121;159, //Hex:  EE799F
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)121/255 blue:(CGFloat)159/255 alpha:1];
		}
			break;
		case paleVioletRed3: { //R;G;B Dec: 205;104;137, //Hex:  CD6889
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)104/255 blue:(CGFloat)137/255 alpha:1];
		}
			break;
		case paleVioletRed4: { //R;G;B Dec: 139;71;93, //Hex:  8B475D
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)71/255 blue:(CGFloat)93/255 alpha:1];
		}
			break;
		case violetRed: { //R;G;B Dec: 208;32;144, //Hex:  D02090
			return [UIColor colorWithRed:(CGFloat)208/255 green:(CGFloat)32/255 blue:(CGFloat)144/255 alpha:1];
		}
			break;
		case violetRed1: { //R;G;B Dec: 255;62;150, //Hex:  FF3E96
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)62/255 blue:(CGFloat)150/255 alpha:1];
		}
			break;
		case violetRed2: { //R;G;B Dec: 238;58;140, //Hex:  EE3A8C
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)58/255 blue:(CGFloat)140/255 alpha:1];
		}
			break;
		case violetRed3: { //R;G;B Dec: 205;50;120, //Hex:  CD3278
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)50/255 blue:(CGFloat)120/255 alpha:1];
		}
			break;
		case violetRed4: { //R;G;B Dec: 139;34;82, //Hex:  8B2252
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)34/255 blue:(CGFloat)82/255 alpha:1];
		}
			break;
		case firebrick: { //R;G;B Dec: 178;34;34, //Hex:  B22222
			return [UIColor colorWithRed:(CGFloat)178/255 green:(CGFloat)34/255 blue:(CGFloat)34/255 alpha:1];
		}
			break;
		case firebrick1: { //R;G;B Dec: 255;48;48, //Hex:  FF3030
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)48/255 blue:(CGFloat)48/255 alpha:1];
		}
			break;
		case firebrick2: { //R;G;B Dec: 238;44;44, //Hex:  EE2C2C
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)44/255 blue:(CGFloat)44/255 alpha:1];
		}
			break;
		case firebrick3: { //R;G;B Dec: 205;38;38, //Hex:  CD2626
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)38/255 blue:(CGFloat)38/255 alpha:1];
		}
			break;
		case firebrick4: { //R;G;B Dec: 139;26;26, //Hex:  8B1A1A
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)26/255 blue:(CGFloat)26/255 alpha:1];
		}
			break;
		case pink: { //R;G;B Dec: 255;192;203, //Hex:  FFC0CB
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)192/255 blue:(CGFloat)203/255 alpha:1];
		}
			break;
		case pink1: { //R;G;B Dec: 238;169;184, //Hex:  EEA9B8
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)169/255 blue:(CGFloat)184/255 alpha:1];
		}
			break;
		case pink2: { //R;G;B Dec: 205;145;158, //Hex:  CD919E
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)145/255 blue:(CGFloat)158/255 alpha:1];
		}
			break;
		case pink3: { //R;G;B Dec: 139;99;108, //Hex:  8B636C
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)99/255 blue:(CGFloat)108/255 alpha:1];
		}
			break;
		case flesh: { //R;G;B Dec: 245;204;176, //Hex:  F5CCB0
			return [UIColor colorWithRed:(CGFloat)245/255 green:(CGFloat)204/255 blue:(CGFloat)176/255 alpha:1];
		}
			break;
		case feldspar: { //R;G;B Dec: 209;146;117, //Hex:  D19275
			return [UIColor colorWithRed:(CGFloat)209/255 green:(CGFloat)146/255 blue:(CGFloat)117/255 alpha:1];
		}
			break;
		case red: { //R;G;B Dec: 255;0;0, //Hex:  FF0000
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)0/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case red1: { //R;G;B Dec: 238;0;0, //Hex:  EE0000
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)0/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case red2: { //R;G;B Dec: 205;0;0, //Hex:  CD0000
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)0/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case red3: { //R;G;B Dec: 139;0;0, //Hex:  8B0000
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)0/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case tomato: { //R;G;B Dec: 255;99;71, //Hex:  FF6347
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)99/255 blue:(CGFloat)71/255 alpha:1];
		}
			break;
		case tomato1: { //R;G;B Dec: 238;92;66, //Hex:  EE5C42
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)92/255 blue:(CGFloat)66/255 alpha:1];
		}
			break;
		case tomato2: { //R;G;B Dec: 205;79;57, //Hex:  CD4F39
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)79/255 blue:(CGFloat)57/255 alpha:1];
		}
			break;
		case tomato3: { //R;G;B Dec: 139;54;38, //Hex:  8B3626
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)54/255 blue:(CGFloat)38/255 alpha:1];
		}
			break;
		case dustyRose: { //R;G;B Dec: 133;99;99, //Hex:  856363
			return [UIColor colorWithRed:(CGFloat)133/255 green:(CGFloat)99/255 blue:(CGFloat)99/255 alpha:1];
		}
			break;
		case firebrick5: { //R;G;B Dec: 142;35;35, //Hex:  8E2323
			return [UIColor colorWithRed:(CGFloat)142/255 green:(CGFloat)35/255 blue:(CGFloat)35/255 alpha:1];
		}
			break;
		case indianRed5: { //R;G;B Dec: 245;204;176, //Hex:  F5CCB0
			return [UIColor colorWithRed:(CGFloat)245/255 green:(CGFloat)204/255 blue:(CGFloat)176/255 alpha:1];
		}
			break;
		case pink4: { //R;G;B Dec: 188;143;143, //Hex:  BC8F8F
			return [UIColor colorWithRed:(CGFloat)188/255 green:(CGFloat)143/255 blue:(CGFloat)143/255 alpha:1];
		}
			break;
		case salmon4: { //R;G;B Dec: 111;66;66, //Hex:  6F4242
			return [UIColor colorWithRed:(CGFloat)111/255 green:(CGFloat)66/255 blue:(CGFloat)66/255 alpha:1];
		}
			break;
		case scarlet: { //R;G;B Dec: 140;23;23, //Hex:  8C1717
			return [UIColor colorWithRed:(CGFloat)140/255 green:(CGFloat)23/255 blue:(CGFloat)23/255 alpha:1];
		}
			break;
		case spicyPink: { //R;G;B Dec: 255;28;174, //Hex:  FF1CAE
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)28/255 blue:(CGFloat)174/255 alpha:1];
		}
			break;
		case freeSpeechRed: { //R;G;B Dec: 192;0;0, //Hex:  C00000
			return [UIColor colorWithRed:(CGFloat)192/255 green:(CGFloat)0/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
	}
	return [UIColor redColor];
}

#pragma mark Shades of Violet
		
+(UIColor *)RGBColorVioletByIndex:(RGBColorVioletName)colorIndex{
	switch (colorIndex) {
		case darkOrchid: { //R;G;B Dec: 153;50;204, //Hex:  9932CC
			return [UIColor colorWithRed:(CGFloat)153/255 green:(CGFloat)50/255 blue:(CGFloat)204/255 alpha:1];
		}
			break;
		case darkOrchid1: { //R;G;B Dec: 191;62;255, //Hex:  BF3EFF
			return [UIColor colorWithRed:(CGFloat)191/255 green:(CGFloat)62/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case darkOrchid2: { //R;G;B Dec: 178;58;238, //Hex:  B23AEE
			return [UIColor colorWithRed:(CGFloat)178/255 green:(CGFloat)58/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case darkOrchid3: { //R;G;B Dec: 154;50;205, //Hex:  9A32CD
			return [UIColor colorWithRed:(CGFloat)154/255 green:(CGFloat)50/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case darkOrchid4: { //R;G;B Dec: 104;34;139, //Hex:  68228B
			return [UIColor colorWithRed:(CGFloat)104/255 green:(CGFloat)34/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case darkViolet: { //R;G;B Dec: 148;0;211, //Hex:  9400D3
			return [UIColor colorWithRed:(CGFloat)148/255 green:(CGFloat)0/255 blue:(CGFloat)211/255 alpha:1];
		}
			break;
		case lavenderBlush: { //R;G;B Dec: 255;240;245, //Hex:  FFF0F5
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)240/255 blue:(CGFloat)245/255 alpha:1];
		}
			break;
		case lavenderBlush1: { //R;G;B Dec: 238;224;229, //Hex:  EEE0E5
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)224/255 blue:(CGFloat)229/255 alpha:1];
		}
			break;
		case lavenderBlush2: { //R;G;B Dec: 205;193;197, //Hex:  CDC1C5
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)193/255 blue:(CGFloat)197/255 alpha:1];
		}
			break;
		case lavenderBlush3: { //R;G;B Dec: 139;131;134, //Hex:  8B8386
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)131/255 blue:(CGFloat)134/255 alpha:1];
		}
			break;
		case mediumOrchid: { //R;G;B Dec: 186;85;211, //Hex:  BA55D3
			return [UIColor colorWithRed:(CGFloat)186/255 green:(CGFloat)85/255 blue:(CGFloat)211/255 alpha:1];
		}
			break;
		case mediumOrchid1: { //R;G;B Dec: 224;102;255, //Hex:  E066FF
			return [UIColor colorWithRed:(CGFloat)224/255 green:(CGFloat)102/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case mediumOrchid2: { //R;G;B Dec: 209;95;238, //Hex:  D15FEE
			return [UIColor colorWithRed:(CGFloat)209/255 green:(CGFloat)95/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case mediumOrchid3: { //R;G;B Dec: 180;82;205, //Hex:  B452CD
			return [UIColor colorWithRed:(CGFloat)180/255 green:(CGFloat)82/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case mediumOrchid4: { //R;G;B Dec: 122;55;139, //Hex:  7A378B
			return [UIColor colorWithRed:(CGFloat)122/255 green:(CGFloat)55/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case mediumPurple1: { //R;G;B Dec: 171;130;255, //Hex:  AB82FF
			return [UIColor colorWithRed:(CGFloat)171/255 green:(CGFloat)130/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case darkOrchid5: { //R;G;B Dec: 153;50;205, //Hex:  9932CD
			return [UIColor colorWithRed:(CGFloat)153/255 green:(CGFloat)50/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case mediumPurple2: { //R;G;B Dec: 159;121;238, //Hex:  9F79EE
			return [UIColor colorWithRed:(CGFloat)159/255 green:(CGFloat)121/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case mediumPurple3: { //R;G;B Dec: 137;104;205, //Hex:  8968CD
			return [UIColor colorWithRed:(CGFloat)137/255 green:(CGFloat)104/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case mediumPurple4: { //R;G;B Dec: 93;71;139, //Hex:  5D478B
			return [UIColor colorWithRed:(CGFloat)93/255 green:(CGFloat)71/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case lavender: { //R;G;B Dec: 230;230;250, //Hex:  E6E6FA
			return [UIColor colorWithRed:(CGFloat)230/255 green:(CGFloat)230/255 blue:(CGFloat)250/255 alpha:1];
		}
			break;
		case magenta: { //R;G;B Dec: 255;0;255, //Hex:  FF00FF
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)0/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case magenta1: { //R;G;B Dec: 238;0;238, //Hex:  EE00EE
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)0/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case magenta2: { //R;G;B Dec: 205;0;205, //Hex:  CD00CD
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)0/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case magenta3: { //R;G;B Dec: 139;0;139, //Hex:  8B008B
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)0/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case maroon: { //R;G;B Dec: 176;48;96, //Hex:  B03060
			return [UIColor colorWithRed:(CGFloat)176/255 green:(CGFloat)48/255 blue:(CGFloat)96/255 alpha:1];
		}
			break;
		case maroon1: { //R;G;B Dec: 255;52;179, //Hex:  FF34B3
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)52/255 blue:(CGFloat)179/255 alpha:1];
		}
			break;
		case maroon2: { //R;G;B Dec: 238;48;167, //Hex:  EE30A7
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)48/255 blue:(CGFloat)167/255 alpha:1];
		}
			break;
		case maroon3: { //R;G;B Dec: 205;41;144, //Hex:  CD2990
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)41/255 blue:(CGFloat)144/255 alpha:1];
		}
			break;
		case maroon4: { //R;G;B Dec: 139;28;98, //Hex:  8B1C62
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)28/255 blue:(CGFloat)98/255 alpha:1];
		}
			break;
		case orchid: { //R;G;B Dec: 219;112;219, //Hex:  DB70DB
			return [UIColor colorWithRed:(CGFloat)219/255 green:(CGFloat)112/255 blue:(CGFloat)219/255 alpha:1];
		}
			break;
		case orchid1: { //R;G;B Dec: 255;131;250, //Hex:  FF83FA
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)131/255 blue:(CGFloat)250/255 alpha:1];
		}
			break;
		case orchid2: { //R;G;B Dec: 238;122;233, //Hex:  EE7AE9
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)122/255 blue:(CGFloat)233/255 alpha:1];
		}
			break;
		case orchid3: { //R;G;B Dec: 205;105;201, //Hex:  CD69C9
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)105/255 blue:(CGFloat)201/255 alpha:1];
		}
			break;
		case orchid4: { //R;G;B Dec: 139;71;137, //Hex:  8B4789
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)71/255 blue:(CGFloat)137/255 alpha:1];
		}
			break;
		case plum: { //R;G;B Dec: 221;160;221, //Hex:  DDA0DD
			return [UIColor colorWithRed:(CGFloat)221/255 green:(CGFloat)160/255 blue:(CGFloat)221/255 alpha:1];
		}
			break;
		case plum1: { //R;G;B Dec: 255;187;255, //Hex:  FFBBFF
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)187/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case plum2: { //R;G;B Dec: 238;174;238, //Hex:  EEAEEE
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)174/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case plum3: { //R;G;B Dec: 205;150;205, //Hex:  CD96CD
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)150/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case plum4: { //R;G;B Dec: 139;102;139, //Hex:  8B668B
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)102/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case purple: { //R;G;B Dec: 160;32;240, //Hex:  A020F0
			return [UIColor colorWithRed:(CGFloat)160/255 green:(CGFloat)32/255 blue:(CGFloat)240/255 alpha:1];
		}
			break;
		case purple1: { //R;G;B Dec: 155;48;255, //Hex:  9B30FF
			return [UIColor colorWithRed:(CGFloat)155/255 green:(CGFloat)48/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case purple2: { //R;G;B Dec: 145;44;238, //Hex:  912CEE
			return [UIColor colorWithRed:(CGFloat)145/255 green:(CGFloat)44/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case purple3: { //R;G;B Dec: 125;38;205, //Hex:  7D26CD
			return [UIColor colorWithRed:(CGFloat)125/255 green:(CGFloat)38/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case purple4: { //R;G;B Dec: 85;26;139, //Hex:  551A8B
			return [UIColor colorWithRed:(CGFloat)85/255 green:(CGFloat)26/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case purple5: { //R;G;B Dec: 128;0;128, //Hex:  800080
			return [UIColor colorWithRed:(CGFloat)128/255 green:(CGFloat)0/255 blue:(CGFloat)128/255 alpha:1];
		}
			break;
		case thistle: { //R;G;B Dec: 216;191;216, //Hex:  D8BFD8
			return [UIColor colorWithRed:(CGFloat)216/255 green:(CGFloat)191/255 blue:(CGFloat)216/255 alpha:1];
		}
			break;
		case thistle1: { //R;G;B Dec: 255;225;255, //Hex:  FFE1FF
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)225/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case thistle2: { //R;G;B Dec: 238;210;238, //Hex:  EED2EE
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)210/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case thistle4: { //R;G;B Dec: 139;123;139, //Hex:  8B7B8B
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)123/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case violet: { //R;G;B Dec: 238;130;238, //Hex:  EE82EE
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)130/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case violetblue: { //R;G;B Dec: 159;95;159, //Hex:  9F5F9F
			return [UIColor colorWithRed:(CGFloat)159/255 green:(CGFloat)95/255 blue:(CGFloat)159/255 alpha:1];
		}
			break;
		case darkPurple: { //R;G;B Dec: 135;31;120, //Hex:  871F78
			return [UIColor colorWithRed:(CGFloat)135/255 green:(CGFloat)31/255 blue:(CGFloat)120/255 alpha:1];
		}
			break;
		case maroon5: { //R;G;B Dec: 245;204;176, //Hex:  F5CCB0
			return [UIColor colorWithRed:(CGFloat)245/255 green:(CGFloat)204/255 blue:(CGFloat)176/255 alpha:1];
		}
			break;
		case maroon6: { //R;G;B Dec: 128;0;0, //Hex:  800000
			return [UIColor colorWithRed:(CGFloat)128/255 green:(CGFloat)0/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case mediumVioletRed1: { //R;G;B Dec: 219;112;147, //Hex:  DB7093
			return [UIColor colorWithRed:(CGFloat)219/255 green:(CGFloat)112/255 blue:(CGFloat)147/255 alpha:1];
		}
			break;
		case neonPink: { //R;G;B Dec: 255;110;199, //Hex:  FF6EC7
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)110/255 blue:(CGFloat)199/255 alpha:1];
		}
			break;
		case plum5: { //R;G;B Dec: 234;173;234, //Hex:  EAADEA
			return [UIColor colorWithRed:(CGFloat)234/255 green:(CGFloat)173/255 blue:(CGFloat)234/255 alpha:1];
		}
			break;
		case turquoise4: { //R;G;B Dec: 173;234;234, //Hex:  ADEAEA
			return [UIColor colorWithRed:(CGFloat)173/255 green:(CGFloat)234/255 blue:(CGFloat)234/255 alpha:1];
		}
			break;
		case violet1: { //R;G;B Dec: 79;47;79, //Hex:  4F2F4F
			return [UIColor colorWithRed:(CGFloat)79/255 green:(CGFloat)47/255 blue:(CGFloat)79/255 alpha:1];
		}
			break;
		case violetRed5: { //R;G;B Dec: 204;50;153, //Hex:  CC3299
			return [UIColor colorWithRed:(CGFloat)204/255 green:(CGFloat)50/255 blue:(CGFloat)153/255 alpha:1];
		}
			break;
	}
	return [UIColor blueColor];
}

#pragma mark Shades of White
		
+(UIColor *)RGBColorWhiteByIndex:(RGBColorWhiteName)colorIndex{
	switch (colorIndex) {
		case antiqueWhite: { //R;G;B Dec: 250;235;215, //Hex:  FAEBD7
			return [UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)235/255 blue:(CGFloat)215/255 alpha:1];
		}
			break;
		case antiqueWhite1: { //R;G;B Dec: 255;239;219, //Hex:  FFEFDB
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)239/255 blue:(CGFloat)219/255 alpha:1];
		}
			break;
		case antiqueWhite2: { //R;G;B Dec: 238;223;204, //Hex:  EEDFCC
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)223/255 blue:(CGFloat)204/255 alpha:1];
		}
			break;
		case antiqueWhite3: { //R;G;B Dec: 205;192;176, //Hex:  CDC0B0
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)192/255 blue:(CGFloat)176/255 alpha:1];
		}
			break;
		case antiqueWhite4: { //R;G;B Dec: 139;131;120, //Hex:  8B8378
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)131/255 blue:(CGFloat)120/255 alpha:1];
		}
			break;
		case floralWhite: { //R;G;B Dec: 255;250;240, //Hex:  FFFAF0
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)250/255 blue:(CGFloat)240/255 alpha:1];
		}
			break;
		case ghostWhite: { //R;G;B Dec: 248;248;255, //Hex:  F8F8FF
			return [UIColor colorWithRed:(CGFloat)248/255 green:(CGFloat)248/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case navajoWhite: { //R;G;B Dec: 255;222;173, //Hex:  FFDEAD
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)222/255 blue:(CGFloat)173/255 alpha:1];
		}
			break;
		case navajoWhite1: { //R;G;B Dec: 238;207;161, //Hex:  EECFA1
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)207/255 blue:(CGFloat)161/255 alpha:1];
		}
			break;
		case navajoWhite2: { //R;G;B Dec: 205;179;139, //Hex:  CDB38B
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)179/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case navajoWhite3: { //R;G;B Dec: 139;121;94, //Hex:  8B795E
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)121/255 blue:(CGFloat)94/255 alpha:1];
		}
			break;
		case oldLace: { //R;G;B Dec: 253;245;230, //Hex:  FDF5E6
			return [UIColor colorWithRed:(CGFloat)253/255 green:(CGFloat)245/255 blue:(CGFloat)230/255 alpha:1];
		}
			break;
		case whiteSmoke: { //R;G;B Dec: 245;245;245, //Hex:  F5F5F5
			return [UIColor colorWithRed:(CGFloat)245/255 green:(CGFloat)245/255 blue:(CGFloat)245/255 alpha:1];
		}
			break;
		case gainsboro: { //R;G;B Dec: 220;220;220, //Hex:  DCDCDC
			return [UIColor colorWithRed:(CGFloat)220/255 green:(CGFloat)220/255 blue:(CGFloat)220/255 alpha:1];
		}
			break;
		case ivory: { //R;G;B Dec: 255;255;240, //Hex:  FFFFF0
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)255/255 blue:(CGFloat)240/255 alpha:1];
		}
			break;
		case ivory1: { //R;G;B Dec: 238;238;224, //Hex:  EEEEE0
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)238/255 blue:(CGFloat)224/255 alpha:1];
		}
			break;
		case ivory2: { //R;G;B Dec: 205;205;193, //Hex:  CDCDC1
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)205/255 blue:(CGFloat)193/255 alpha:1];
		}
			break;
		case ivory3: { //R;G;B Dec: 139;139;131, //Hex:  8B8B83
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)139/255 blue:(CGFloat)131/255 alpha:1];
		}
			break;
		case linen: { //R;G;B Dec: 250;240;230, //Hex:  FAF0E6
			return [UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)240/255 blue:(CGFloat)230/255 alpha:1];
		}
			break;
		case seashell: { //R;G;B Dec: 255;245;238, //Hex:  FFF5EE
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)245/255 blue:(CGFloat)238/255 alpha:1];
		}
			break;
		case seashell1: { //R;G;B Dec: 238;229;222, //Hex:  EEE5DE
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)229/255 blue:(CGFloat)222/255 alpha:1];
		}
			break;
		case seashell2: { //R;G;B Dec: 205;197;191, //Hex:  CDC5BF
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)197/255 blue:(CGFloat)191/255 alpha:1];
		}
			break;
		case seashell3: { //R;G;B Dec: 139;134;130, //Hex:  8B8682
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)134/255 blue:(CGFloat)130/255 alpha:1];
		}
			break;
		case snow: { //R;G;B Dec: 255;250;250, //Hex:  FFFAFA
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)250/255 blue:(CGFloat)250/255 alpha:1];
		}
			break;
		case snow1: { //R;G;B Dec: 238;233;233, //Hex:  EEE9E9
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)233/255 blue:(CGFloat)233/255 alpha:1];
		}
			break;
		case snow2: { //R;G;B Dec: 205;201;201, //Hex:  CDC9C9
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)201/255 blue:(CGFloat)201/255 alpha:1];
		}
			break;
		case snow3: { //R;G;B Dec: 139;137;137, //Hex:  8B8989
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)137/255 blue:(CGFloat)137/255 alpha:1];
		}
			break;
		case wheat: { //R;G;B Dec: 245;222;179, //Hex:  F5DEB3
			return [UIColor colorWithRed:(CGFloat)245/255 green:(CGFloat)222/255 blue:(CGFloat)179/255 alpha:1];
		}
			break;
		case wheat1: { //R;G;B Dec: 255;231;186, //Hex:  FFE7BA
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)231/255 blue:(CGFloat)186/255 alpha:1];
		}
			break;
		case wheat2: { //R;G;B Dec: 205;186;150, //Hex:  CDBA96
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)186/255 blue:(CGFloat)150/255 alpha:1];
		}
			break;
		case wheat3: { //R;G;B Dec: 139;126;102, //Hex:  8B7E66
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)126/255 blue:(CGFloat)102/255 alpha:1];
		}
			break;
		case white: { //R;G;B Dec: 255;255;255, //Hex:  FFFFFF
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)255/255 blue:(CGFloat)255/255 alpha:1];
		}
			break;
		case quartz: { //R;G;B Dec: 217;217;243, //Hex:  D9D9F3
			return [UIColor colorWithRed:(CGFloat)217/255 green:(CGFloat)217/255 blue:(CGFloat)243/255 alpha:1];
		}
			break;
		case wheat4: { //R;G;B Dec: 216;216;191, //Hex:  D8D8BF
			return [UIColor colorWithRed:(CGFloat)216/255 green:(CGFloat)216/255 blue:(CGFloat)191/255 alpha:1];
		}
			break;
	}
	return [UIColor whiteColor];
}

#pragma mark Shades of Yellow
		
+(UIColor *)RGBColorYellowByIndex:(RGBColorYellowName)colorIndex{
	switch (colorIndex) {
		case blanchedAlmond: { //R;G;B Dec: 255;235;205, //Hex:  FFEBCD
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)235/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case darkGoldenrod: { //R;G;B Dec: 184;134;11, //Hex:  B8860B
			return [UIColor colorWithRed:(CGFloat)184/255 green:(CGFloat)134/255 blue:(CGFloat)11/255 alpha:1];
		}
			break;
		case darkGoldenrod1: { //R;G;B Dec: 255;185;15, //Hex:  FFB90F
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)185/255 blue:(CGFloat)15/255 alpha:1];
		}
			break;
		case darkGoldenrod2: { //R;G;B Dec: 238;173;14, //Hex:  EEAD0E
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)173/255 blue:(CGFloat)14/255 alpha:1];
		}
			break;
		case darkGoldenrod3: { //R;G;B Dec: 205;149;12, //Hex:  CD950C
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)149/255 blue:(CGFloat)12/255 alpha:1];
		}
			break;
		case darkGoldenrod4: { //R;G;B Dec: 139;101;8, //Hex:  8B6508
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)101/255 blue:(CGFloat)8/255 alpha:1];
		}
			break;
		case lemonChiffon: { //R;G;B Dec: 255;250;205, //Hex:  FFFACD
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)250/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case lemonChiffon1: { //R;G;B Dec: 238;233;191, //Hex:  EEE9BF
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)233/255 blue:(CGFloat)191/255 alpha:1];
		}
			break;
		case lemonChiffon2: { //R;G;B Dec: 205;201;165, //Hex:  CDC9A5
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)201/255 blue:(CGFloat)165/255 alpha:1];
		}
			break;
		case lemonChiffon3: { //R;G;B Dec: 139;137;112, //Hex:  8B8970
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)137/255 blue:(CGFloat)112/255 alpha:1];
		}
			break;
		case lightGoldenrod: { //R;G;B Dec: 238;221;130, //Hex:  EEDD82
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)221/255 blue:(CGFloat)130/255 alpha:1];
		}
			break;
		case lightGoldenrod1: { //R;G;B Dec: 255;236;139, //Hex:  FFEC8B
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)236/255 blue:(CGFloat)139/255 alpha:1];
		}
			break;
		case lightGoldenrod2: { //R;G;B Dec: 205;190;112, //Hex:  CDBE70
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)190/255 blue:(CGFloat)112/255 alpha:1];
		}
			break;
		case lightGoldenrod3: { //R;G;B Dec: 139;129;76, //Hex:  8B814C
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)129/255 blue:(CGFloat)76/255 alpha:1];
		}
			break;
		case lightYellow: { //R;G;B Dec: 255;255;224, //Hex:  FFFFE0
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)255/255 blue:(CGFloat)224/255 alpha:1];
		}
			break;
		case lightYellow1: { //R;G;B Dec: 238;238;209, //Hex:  EEEED1
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)238/255 blue:(CGFloat)209/255 alpha:1];
		}
			break;
		case lightYellow2: { //R;G;B Dec: 205;205;180, //Hex:  CDCDB4
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)205/255 blue:(CGFloat)180/255 alpha:1];
		}
			break;
		case lightYellow3: { //R;G;B Dec: 139;139;122, //Hex:  8B8B7A
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)139/255 blue:(CGFloat)122/255 alpha:1];
		}
			break;
		case paleGoldenrod: { //R;G;B Dec: 238;232;170, //Hex:  EEE8AA
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)232/255 blue:(CGFloat)170/255 alpha:1];
		}
			break;
		case papayaWhip: { //R;G;B Dec: 255;239;213, //Hex:  FFEFD5
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)239/255 blue:(CGFloat)213/255 alpha:1];
		}
			break;
		case cornsilk: { //R;G;B Dec: 255;248;220, //Hex:  FFF8DC
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)248/255 blue:(CGFloat)220/255 alpha:1];
		}
			break;
		case cornsilk1: { //R;G;B Dec: 238;232;205, //Hex:  EEE8CD
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)232/255 blue:(CGFloat)205/255 alpha:1];
		}
			break;
		case cornsilk2: { //R;G;B Dec: 205;200;177, //Hex:  CDC8B1
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)200/255 blue:(CGFloat)177/255 alpha:1];
		}
			break;
		case cornsilk3: { //R;G;B Dec: 139;136;120, //Hex:  8B8878
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)136/255 blue:(CGFloat)120/255 alpha:1];
		}
			break;
		case goldenrod: { //R;G;B Dec: 218;165;32, //Hex:  DAA520
			return [UIColor colorWithRed:(CGFloat)218/255 green:(CGFloat)165/255 blue:(CGFloat)32/255 alpha:1];
		}
			break;
		case goldenrod1: { //R;G;B Dec: 255;193;37, //Hex:  FFC125
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)193/255 blue:(CGFloat)37/255 alpha:1];
		}
			break;
		case goldenrod2: { //R;G;B Dec: 238;180;34, //Hex:  EEB422
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)180/255 blue:(CGFloat)34/255 alpha:1];
		}
			break;
		case goldenrod3: { //R;G;B Dec: 139;105;20, //Hex:  8B6914
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)105/255 blue:(CGFloat)20/255 alpha:1];
		}
			break;
		case moccasin: { //R;G;B Dec: 255;228;181, //Hex:  FFE4B5
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)228/255 blue:(CGFloat)181/255 alpha:1];
		}
			break;
		case yellow: { //R;G;B Dec: 255;255;0, //Hex:  FFFF00
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)255/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case yellow1: { //R;G;B Dec: 205;205;0, //Hex:  CDCD00
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)205/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case yellow2: { //R;G;B Dec: 139;139;0, //Hex:  8B8B00
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)139/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case gold: { //R;G;B Dec: 255;215;0, //Hex:  FFD700
			return [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)215/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case gold1: { //R;G;B Dec: 238;201;0, //Hex:  EEC900
			return [UIColor colorWithRed:(CGFloat)238/255 green:(CGFloat)201/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case gold2: { //R;G;B Dec: 205;173;0, //Hex:  CDAD00
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)173/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case gold3: { //R;G;B Dec: 139;117;0, //Hex:  8B7500
			return [UIColor colorWithRed:(CGFloat)139/255 green:(CGFloat)117/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case goldenrod4: { //R;G;B Dec: 219;219;112, //Hex:  DBDB70
			return [UIColor colorWithRed:(CGFloat)219/255 green:(CGFloat)219/255 blue:(CGFloat)112/255 alpha:1];
		}
			break;
		case mediumGoldenrod: { //R;G;B Dec: 234;234;174, //Hex:  EAEAAE
			return [UIColor colorWithRed:(CGFloat)234/255 green:(CGFloat)234/255 blue:(CGFloat)174/255 alpha:1];
		}
			break;
		case yellowGreen1: { //R;G;B Dec: 153;204;50, //Hex:  99CC32
			return [UIColor colorWithRed:(CGFloat)153/255 green:(CGFloat)204/255 blue:(CGFloat)50/255 alpha:1];
		}
			break;
	}
	return [UIColor yellowColor];
}

#pragma mark Shades of Metal
		
+(UIColor *)RGBColorMetalByIndex:(RGBColorMetalName)colorIndex{
	switch (colorIndex) {
		case copper: { //R;G;B Dec: 184;115;51, //Hex:  B87333
			return [UIColor colorWithRed:(CGFloat)184/255 green:(CGFloat)115/255 blue:(CGFloat)51/255 alpha:1];
		}
			break;
		case coolCopper: { //R;G;B Dec: 217;135;25, //Hex:  D98719
			return [UIColor colorWithRed:(CGFloat)217/255 green:(CGFloat)135/255 blue:(CGFloat)25/255 alpha:1];
		}
			break;
		case greenCopper: { //R;G;B Dec: 133;99;99, //Hex:  856363
			return [UIColor colorWithRed:(CGFloat)133/255 green:(CGFloat)99/255 blue:(CGFloat)99/255 alpha:1];
		}
			break;
		case brass: { //R;G;B Dec: 181;166;66, //Hex:  B5A642
			return [UIColor colorWithRed:(CGFloat)181/255 green:(CGFloat)166/255 blue:(CGFloat)66/255 alpha:1];
		}
			break;
		case bronze: { //R;G;B Dec: 140;120;83, //Hex:  8C7853
			return [UIColor colorWithRed:(CGFloat)140/255 green:(CGFloat)120/255 blue:(CGFloat)83/255 alpha:1];
		}
			break;
		case bronzeII: { //R;G;B Dec: 166;125;61, //Hex:  A67D3D
			return [UIColor colorWithRed:(CGFloat)166/255 green:(CGFloat)125/255 blue:(CGFloat)61/255 alpha:1];
		}
			break;
		case brightGold: { //R;G;B Dec: 217;217;25, //Hex:  D9D919
			return [UIColor colorWithRed:(CGFloat)217/255 green:(CGFloat)217/255 blue:(CGFloat)25/255 alpha:1];
		}
			break;
		case oldGold: { //R;G;B Dec: 207;181;59, //Hex:  CFB53B
			return [UIColor colorWithRed:(CGFloat)207/255 green:(CGFloat)181/255 blue:(CGFloat)59/255 alpha:1];
		}
			break;
		case cSSGold: { //R;G;B Dec: 204;153;0, //Hex:  CC9900
			return [UIColor colorWithRed:(CGFloat)204/255 green:(CGFloat)153/255 blue:(CGFloat)0/255 alpha:1];
		}
			break;
		case gold4: { //R;G;B Dec: 205;127;50, //Hex:  CD7F32
			return [UIColor colorWithRed:(CGFloat)205/255 green:(CGFloat)127/255 blue:(CGFloat)50/255 alpha:1];
		}
			break;
		case silver: { //R;G;B Dec: 230;232;250, //Hex:  E6E8FA
			return [UIColor colorWithRed:(CGFloat)230/255 green:(CGFloat)232/255 blue:(CGFloat)250/255 alpha:1];
		}
			break;
		case silver_Grey: { //R;G;B Dec: 192;192;192, //Hex:  C0C0C0
			return [UIColor colorWithRed:(CGFloat)192/255 green:(CGFloat)192/255 blue:(CGFloat)192/255 alpha:1];
		}
			break;
		case lightSteelBlue5: { //R;G;B Dec: 84;84;84, //Hex:  545454
			return [UIColor colorWithRed:(CGFloat)84/255 green:(CGFloat)84/255 blue:(CGFloat)84/255 alpha:1];
		}
			break;
		case steelBlue7: { //R;G;B Dec: 35;107;142, //Hex:  236B8E
			return [UIColor colorWithRed:(CGFloat)35/255 green:(CGFloat)107/255 blue:(CGFloat)142/255 alpha:1];
		}
			break;
	}	
	return [UIColor magentaColor];	
}

#pragma mark Shades of Black and Gray 
+(NSMutableArray *)getRGBColorBlackGreyList{
	NSMutableArray *ret=[NSMutableArray arrayWithCapacity:10];
	[ret addObject:@"Grey"];
	[ret addObject:@"Grey_Silver"];
	[ret addObject:@"LightGray"];
	[ret addObject:@"SlateGray"];
	[ret addObject:@"SlateGray1"];
	[ret addObject:@"SlateGray3"];
	[ret addObject:@"Black"];
	[ret addObject:@"Grey1"];
	[ret addObject:@"Grey2"];
	[ret addObject:@"Grey3"];
	[ret addObject:@"Grey4"];
	[ret addObject:@"Grey5"];
	[ret addObject:@"Grey6"];
	[ret addObject:@"Dark Slate Grey"];
	[ret addObject:@"Dim Grey"];
	[ret addObject:@"Light Grey"];
	[ret addObject:@"Very Light Grey"];
	[ret addObject:@"Free Speech Grey"];
	
	return ret;
}	
	
#pragma mark Shades of Blue
	
+(NSMutableArray *)getRGBColorBlueList{
	NSMutableArray *ret=[NSMutableArray arrayWithCapacity:10];
	[ret addObject:@"AliceBlue"];
	[ret addObject:@"BlueViolet"];
	[ret addObject:@"Cadet Blue"];
	[ret addObject:@"CadetBlue1"];
	[ret addObject:@"CadetBlue2"];
	[ret addObject:@"CornFlowerBlue1"];
	[ret addObject:@"DarkSlateBlue"];
	[ret addObject:@"DarkTurquoise"];
	[ret addObject:@"DeepSkyBlue"];
	[ret addObject:@"DeepSkyBlue1"];
	[ret addObject:@"DeepSkyBlue2"];
	[ret addObject:@"DeepSkyBlue3"];
	[ret addObject:@"DodgerBlue"];
	[ret addObject:@"DodgerBlue1"];
	[ret addObject:@"DodgerBlue2"];
	[ret addObject:@"DodgerBlue3"];
	[ret addObject:@"DodgerBlue4"];
	[ret addObject:@"LightBlue"];
	[ret addObject:@"LightBlue1"];
	[ret addObject:@"LightBlue3"];
	[ret addObject:@"LightBlue4"];
	[ret addObject:@"LightCyan"];
	[ret addObject:@"LightCyan1"];
	[ret addObject:@"LightCyan2"];
	[ret addObject:@"LightCyan3"];
	[ret addObject:@"LightSkyBlue"];
	[ret addObject:@"LightSkyBlue1"];
	[ret addObject:@"LightSkyBlue2"];
	[ret addObject:@"LightSkyBlue3"];
	[ret addObject:@"LightSkyBlue4"];
	[ret addObject:@"LightSlateBlue"];
	[ret addObject:@"LightSlateBlue1"];
	[ret addObject:@"LightSteelBlue"];
	[ret addObject:@"LightSteelBlue1"];
	[ret addObject:@"LightSteelBlue2"];
	[ret addObject:@"LightSteelBlue3"];
	[ret addObject:@"LightSteelBlue4"];
	[ret addObject:@"Aquamarine"];
	[ret addObject:@"MediumBlue"];
	[ret addObject:@"MediumSlateBlue"];
	[ret addObject:@"MediumTurquoise"];
	[ret addObject:@"MidnightBlue"];
	[ret addObject:@"NavyBlue"];
	[ret addObject:@"PaleTurquoise"];
	[ret addObject:@"PaleTurquoise1"];
	[ret addObject:@"PaleTurquoise2"];
	[ret addObject:@"PaleTurquoise3"];
	[ret addObject:@"PowderBlue"];
	[ret addObject:@"RoyalBlue"];
	[ret addObject:@"RoyalBlue1"];
	[ret addObject:@"RoyalBlue2"];
	[ret addObject:@"RoyalBlue3"];
	[ret addObject:@"RoyalBlue4"];
	[ret addObject:@"SkyBlue"];
	[ret addObject:@"SkyBlue1"];
	[ret addObject:@"SkyBlue2"];
	[ret addObject:@"SkyBlue3"];
	[ret addObject:@"SlateBlue"];
	[ret addObject:@"SlateBlue1"];
	[ret addObject:@"SlateBlue2"];
	[ret addObject:@"SlateBlue3"];
	[ret addObject:@"SlateBlue4"];
	[ret addObject:@"SteelBlue"];
	[ret addObject:@"SteelBlue1"];
	[ret addObject:@"SteelBlue2"];
	[ret addObject:@"SteelBlue3"];
	[ret addObject:@"SteelBlue4"];
	[ret addObject:@"SteelBlue5"];
	[ret addObject:@"SteelBlue6"];
	[ret addObject:@"MediumAquamarine"];
	[ret addObject:@"Aquamarine1"];
	[ret addObject:@"Azure"];
	[ret addObject:@"Azure1"];
	[ret addObject:@"Azure2"];
	[ret addObject:@"Azure3"];
	[ret addObject:@"Blue"];
	[ret addObject:@"Blue1"];
	[ret addObject:@"Blue2"];
	[ret addObject:@"Blue3"];
	[ret addObject:@"Aqua"];
	[ret addObject:@"Cyan"];
	[ret addObject:@"Cyan1"];
	[ret addObject:@"Cyan2"];
	[ret addObject:@"Navy"];
	[ret addObject:@"Teal"];
	[ret addObject:@"Turquoise"];
	[ret addObject:@"Turquoise1"];
	[ret addObject:@"Turquoise2"];
	[ret addObject:@"Turquoise3"];
	[ret addObject:@"DarkSlateGray"];
	[ret addObject:@"DarkSlateGray1"];
	[ret addObject:@"DarkSlateGray2"];
	[ret addObject:@"DarkSlateGray3"];
	[ret addObject:@"Dark Slate Blue1"];
	[ret addObject:@"Dark Turquoise1"];
	[ret addObject:@"Medium Slate Blue1"];
	[ret addObject:@"Midnight Blue1"];
	[ret addObject:@"Navy Blue1"];
	[ret addObject:@"Neon Blue"];
	[ret addObject:@"Rich Blue"];
	[ret addObject:@"Slate Blue5"];
	[ret addObject:@"Summer Sky"];
	[ret addObject:@"Iris Blue"];
	[ret addObject:@"Free Speech Blue"];
	
	return ret;
}

#pragma mark Shades of Brown
	
+(NSMutableArray *)getRGBColorBrownList{
	NSMutableArray *ret=[NSMutableArray arrayWithCapacity:10];
	[ret addObject:@"RosyBrown"];
	[ret addObject:@"RosyBrown1"];
	[ret addObject:@"RosyBrown2"];
	[ret addObject:@"RosyBrown3"];
	[ret addObject:@"RosyBrown4"];
	[ret addObject:@"SaddleBrown"];
	[ret addObject:@"SandyBrown"];
	[ret addObject:@"Beige"];
	[ret addObject:@"Brown"];
	[ret addObject:@"Brown1"];
	[ret addObject:@"Brown2"];
	[ret addObject:@"Brown3"];
	[ret addObject:@"Brown4"];
	[ret addObject:@"Dark Brown"];
	[ret addObject:@"Burlywood"];
	[ret addObject:@"Burlywood1"];
	[ret addObject:@"Burlywood2"];
	[ret addObject:@"BakersChocolate"];
	[ret addObject:@"Chocolate"];
	[ret addObject:@"Chocolate1"];
	[ret addObject:@"Chocolate2"];
	[ret addObject:@"Chocolate3"];
	[ret addObject:@"Peru"];
	[ret addObject:@"Tan"];
	[ret addObject:@"Tan1"];
	[ret addObject:@"Tan2"];
	[ret addObject:@"Dark Tan"];
	[ret addObject:@"Dark Wood"];
	[ret addObject:@"Light Wood"];
	[ret addObject:@"Medium Wood"];
	[ret addObject:@"New Tan"];
	[ret addObject:@"Sienna5"];
	[ret addObject:@"Tan3"];
	[ret addObject:@"Very Dark Brown"];
	
	return ret;
}

#pragma mark Shades of Green

+(NSMutableArray *)getRGBColorGreenList{
	NSMutableArray *ret=[NSMutableArray arrayWithCapacity:10];
	[ret addObject:@"Dark Green"];
	[ret addObject:@"DarkGreen1"];
	[ret addObject:@"Dark green copper"];
	[ret addObject:@"DarkKhaki"];
	[ret addObject:@"DarkOliveGreen"];
	[ret addObject:@"DarkOliveGreen1"];
	[ret addObject:@"DarkOliveGreen2"];
	[ret addObject:@"DarkOliveGreen3"];
	[ret addObject:@"DarkOliveGreen4"];
	[ret addObject:@"Olive"];
	[ret addObject:@"DarkSeaGreen"];
	[ret addObject:@"DarkSeaGreen1"];
	[ret addObject:@"DarkSeaGreen2"];
	[ret addObject:@"DarkSeaGreen3"];
	[ret addObject:@"ForestGreen"];
	[ret addObject:@"GreenYellow"];
	[ret addObject:@"LawnGreen"];
	[ret addObject:@"LightSeaGreen"];
	[ret addObject:@"LimeGreen"];
	[ret addObject:@"MediumSeaGreen"];
	[ret addObject:@"MediumSpringGreen"];
	[ret addObject:@"OliveDrab"];
	[ret addObject:@"OliveDrab1"];
	[ret addObject:@"OliveDrab2"];
	[ret addObject:@"OliveDrab3"];
	[ret addObject:@"OliveDrab4"];
	[ret addObject:@"PaleGreen"];
	[ret addObject:@"PaleGreen1"];
	[ret addObject:@"PaleGreen2"];
	[ret addObject:@"SeaGreen"];
	[ret addObject:@"SeaGreen1"];
	[ret addObject:@"SeaGreen2"];
	[ret addObject:@"SpringGreen"];
	[ret addObject:@"SpringGreen1"];
	[ret addObject:@"YellowGreen"];
	[ret addObject:@"Chartreuse"];
	[ret addObject:@"Chartreuse1"];
	[ret addObject:@"Chartreuse2"];
	[ret addObject:@"Green"];
	[ret addObject:@"Green1"];
	[ret addObject:@"Khaki"];
	[ret addObject:@"Khaki1"];
	[ret addObject:@"Khaki2"];
	[ret addObject:@"Dark Olive Green5"];
	[ret addObject:@"Green Yellow1"];
	[ret addObject:@"Hunter Green"];
	[ret addObject:@"Forest Green1"];
	[ret addObject:@"Lime Green1"];
	[ret addObject:@"Medium Forest Green"];
	[ret addObject:@"Medium Sea Green1"];
	[ret addObject:@"Medium Spring Green1"];
	[ret addObject:@"Pale Green3"];
	[ret addObject:@"Sea Green3"];
	[ret addObject:@"Spring Green2"];
	[ret addObject:@"Free Speech Green"];

	return ret;
}

#pragma mark Shades of Orange

+(NSMutableArray *)getRGBColorOrangeList{
	NSMutableArray *ret=[NSMutableArray arrayWithCapacity:10];
	[ret addObject:@"DarkOrange"];
	[ret addObject:@"DarkOrange1"];
	[ret addObject:@"DarkOrange2"];
	[ret addObject:@"DarkSalmon"];
	[ret addObject:@"LightCoral"];
	[ret addObject:@"LightSalmon"];
	[ret addObject:@"LightSalmon1"];
	[ret addObject:@"PeachPuff"];
	[ret addObject:@"PeachPuff1"];
	[ret addObject:@"PeachPuff2"];
	[ret addObject:@"PeachPuff3"];
	[ret addObject:@"Bisque"];
	[ret addObject:@"Bisque1"];
	[ret addObject:@"Bisque2"];
	[ret addObject:@"Bisque3"];
	[ret addObject:@"Coral"];
	[ret addObject:@"Coral1"];
	[ret addObject:@"Coral2"];
	[ret addObject:@"Coral3"];
	[ret addObject:@"Honeydew"];
	[ret addObject:@"Honeydew1"];
	[ret addObject:@"Honeydew2"];
	[ret addObject:@"Honeydew3"];
	[ret addObject:@"Orange"];
	[ret addObject:@"Orange1"];
	[ret addObject:@"Orange2"];
	[ret addObject:@"Orange3"];
	[ret addObject:@"Salmon"];
	[ret addObject:@"Salmon1"];
	[ret addObject:@"Salmon2"];
	[ret addObject:@"Salmon3"];
	[ret addObject:@"Sienna"];
	[ret addObject:@"Sienna1"];
	[ret addObject:@"Sienna2"];
	[ret addObject:@"Sienna3"];
	[ret addObject:@"Sienna4"];
	[ret addObject:@"Mandarian Orange"];
	[ret addObject:@"Orange4"];
	[ret addObject:@"Orange Red4"];
	
	return ret;
}

#pragma mark Shades of Red
	
+(NSMutableArray *)getRGBColorRedList{
	NSMutableArray *ret=[NSMutableArray arrayWithCapacity:10];
	[ret addObject:@"DeepPink"];
	[ret addObject:@"DeepPink1"];
	[ret addObject:@"DeepPink2"];
	[ret addObject:@"DeepPink3"];
	[ret addObject:@"HotPink"];
	[ret addObject:@"HotPink1"];
	[ret addObject:@"HotPink2"];
	[ret addObject:@"HotPink3"];
	[ret addObject:@"IndianRed"];
	[ret addObject:@"IndianRed1"];
	[ret addObject:@"IndianRed2"];
	[ret addObject:@"IndianRed3"];
	[ret addObject:@"IndianRed4"];
	[ret addObject:@"LightPink"];
	[ret addObject:@"LightPink1"];
	[ret addObject:@"LightPink2"];
	[ret addObject:@"LightPink3"];
	[ret addObject:@"MediumVioletRed"];
	[ret addObject:@"MistyRose"];
	[ret addObject:@"MistyRose1"];
	[ret addObject:@"MistyRose2"];
	[ret addObject:@"MistyRose3"];
	[ret addObject:@"OrangeRed"];
	[ret addObject:@"OrangeRed1"];
	[ret addObject:@"OrangeRed2"];
	[ret addObject:@"OrangeRed3"];
	[ret addObject:@"PaleVioletRed"];
	[ret addObject:@"PaleVioletRed1"];
	[ret addObject:@"PaleVioletRed2"];
	[ret addObject:@"PaleVioletRed3"];
	[ret addObject:@"PaleVioletRed4"];
	[ret addObject:@"VioletRed"];
	[ret addObject:@"VioletRed1"];
	[ret addObject:@"VioletRed2"];
	[ret addObject:@"VioletRed3"];
	[ret addObject:@"VioletRed4"];
	[ret addObject:@"Firebrick"];
	[ret addObject:@"Firebrick1"];
	[ret addObject:@"Firebrick2"];
	[ret addObject:@"Firebrick3"];
	[ret addObject:@"Firebrick4"];
	[ret addObject:@"Pink"];
	[ret addObject:@"Pink1"];
	[ret addObject:@"Pink2"];
	[ret addObject:@"Pink3"];
	[ret addObject:@"Flesh"];
	[ret addObject:@"Feldspar"];
	[ret addObject:@"Red"];
	[ret addObject:@"Red1"];
	[ret addObject:@"Red2"];
	[ret addObject:@"Red3"];
	[ret addObject:@"Tomato"];
	[ret addObject:@"Tomato1"];
	[ret addObject:@"Tomato2"];
	[ret addObject:@"Tomato3"];
	[ret addObject:@"Dusty Rose"];
	[ret addObject:@"Firebrick5"];
	[ret addObject:@"Indian Red5"];
	[ret addObject:@"Pink4"];
	[ret addObject:@"Salmon4"];
	[ret addObject:@"Scarlet"];
	[ret addObject:@"Spicy Pink"];
	[ret addObject:@"Free Speech Red"];

	return ret;
}

#pragma mark Shades of Violet

+(NSMutableArray *)getRGBColorVioletList{
	NSMutableArray *ret=[NSMutableArray arrayWithCapacity:10];
	[ret addObject:@"DarkOrchid"];
	[ret addObject:@"DarkOrchid1"];
	[ret addObject:@"DarkOrchid2"];
	[ret addObject:@"DarkOrchid3"];
	[ret addObject:@"DarkOrchid4"];
	[ret addObject:@"DarkViolet"];
	[ret addObject:@"LavenderBlush"];
	[ret addObject:@"LavenderBlush1"];
	[ret addObject:@"LavenderBlush2"];
	[ret addObject:@"LavenderBlush3"];
	[ret addObject:@"MediumOrchid"];
	[ret addObject:@"MediumOrchid1"];
	[ret addObject:@"MediumOrchid2"];
	[ret addObject:@"MediumOrchid3"];
	[ret addObject:@"MediumOrchid4"];
	[ret addObject:@"MediumPurple1"];
	[ret addObject:@"Dark Orchid5"];
	[ret addObject:@"MediumPurple2"];
	[ret addObject:@"MediumPurple3"];
	[ret addObject:@"MediumPurple4"];
	[ret addObject:@"Lavender"];
	[ret addObject:@"Magenta"];
	[ret addObject:@"Magenta1"];
	[ret addObject:@"Magenta2"];
	[ret addObject:@"Magenta3"];
	[ret addObject:@"Maroon"];
	[ret addObject:@"Maroon1"];
	[ret addObject:@"Maroon2"];
	[ret addObject:@"Maroon3"];
	[ret addObject:@"Maroon4"];
	[ret addObject:@"Orchid"];
	[ret addObject:@"Orchid1"];
	[ret addObject:@"Orchid2"];
	[ret addObject:@"Orchid3"];
	[ret addObject:@"Orchid4"];
	[ret addObject:@"Plum"];
	[ret addObject:@"Plum1"];
	[ret addObject:@"Plum2"];
	[ret addObject:@"Plum3"];
	[ret addObject:@"Plum4"];
	[ret addObject:@"Purple"];
	[ret addObject:@"Purple1"];
	[ret addObject:@"Purple2"];
	[ret addObject:@"Purple3"];
	[ret addObject:@"Purple4"];
	[ret addObject:@"Purple5"];
	[ret addObject:@"Thistle"];
	[ret addObject:@"Thistle1"];
	[ret addObject:@"Thistle2"];
	[ret addObject:@"Thistle4"];
	[ret addObject:@"Violet"];
	[ret addObject:@"Violet blue"];
	[ret addObject:@"Dark Purple"];
	[ret addObject:@"Maroon5"];
	[ret addObject:@"Maroon6"];
	[ret addObject:@"Medium Violet Red1"];
	[ret addObject:@"Neon Pink"];
	[ret addObject:@"Plum5"];
	[ret addObject:@"Turquoise4"];
	[ret addObject:@"Violet1"];
	[ret addObject:@"Violet Red5"];

	return ret;
}

#pragma mark Shades of White
	
+(NSMutableArray *)getRGBColorWhiteList{
	NSMutableArray *ret=[NSMutableArray arrayWithCapacity:10];
	[ret addObject:@"AntiqueWhite"];
	[ret addObject:@"AntiqueWhite1"];
	[ret addObject:@"AntiqueWhite2"];
	[ret addObject:@"AntiqueWhite3"];
	[ret addObject:@"AntiqueWhite4"];
	[ret addObject:@"FloralWhite"];
	[ret addObject:@"GhostWhite"];
	[ret addObject:@"NavajoWhite"];
	[ret addObject:@"NavajoWhite1"];
	[ret addObject:@"NavajoWhite2"];
	[ret addObject:@"NavajoWhite3"];
	[ret addObject:@"OldLace"];
	[ret addObject:@"WhiteSmoke"];
	[ret addObject:@"Gainsboro"];
	[ret addObject:@"Ivory"];
	[ret addObject:@"Ivory1"];
	[ret addObject:@"Ivory2"];
	[ret addObject:@"Ivory3"];
	[ret addObject:@"Linen"];
	[ret addObject:@"Seashell"];
	[ret addObject:@"Seashell1"];
	[ret addObject:@"Seashell2"];
	[ret addObject:@"Seashell3"];
	[ret addObject:@"Snow"];
	[ret addObject:@"Snow1"];
	[ret addObject:@"Snow2"];
	[ret addObject:@"Snow3"];
	[ret addObject:@"Wheat"];
	[ret addObject:@"Wheat1"];
	[ret addObject:@"Wheat2"];
	[ret addObject:@"Wheat3"];
	[ret addObject:@"White"];
	[ret addObject:@"Quartz"];
	[ret addObject:@"Wheat4"];

	return ret;
}

#pragma mark Shades of Yellow
	
+(NSMutableArray *)getRGBColorYellowList{
	NSMutableArray *ret=[NSMutableArray arrayWithCapacity:10];
	[ret addObject:@"BlanchedAlmond"];
	[ret addObject:@"DarkGoldenrod"];
	[ret addObject:@"DarkGoldenrod1"];
	[ret addObject:@"DarkGoldenrod2"];
	[ret addObject:@"DarkGoldenrod3"];
	[ret addObject:@"DarkGoldenrod4"];
	[ret addObject:@"LemonChiffon"];
	[ret addObject:@"LemonChiffon1"];
	[ret addObject:@"LemonChiffon2"];
	[ret addObject:@"LemonChiffon3"];
	[ret addObject:@"LightGoldenrod"];
	[ret addObject:@"LightGoldenrod1"];
	[ret addObject:@"LightGoldenrod2"];
	[ret addObject:@"LightGoldenrod3"];
	[ret addObject:@"LightYellow"];
	[ret addObject:@"LightYellow1"];
	[ret addObject:@"LightYellow2"];
	[ret addObject:@"LightYellow3"];
	[ret addObject:@"PaleGoldenrod"];
	[ret addObject:@"PapayaWhip"];
	[ret addObject:@"Cornsilk"];
	[ret addObject:@"Cornsilk1"];
	[ret addObject:@"Cornsilk2"];
	[ret addObject:@"Cornsilk3"];
	[ret addObject:@"Goldenrod"];
	[ret addObject:@"Goldenrod1"];
	[ret addObject:@"Goldenrod2"];
	[ret addObject:@"Goldenrod3"];
	[ret addObject:@"Moccasin"];
	[ret addObject:@"Yellow"];
	[ret addObject:@"Yellow1"];
	[ret addObject:@"Yellow2"];
	[ret addObject:@"Gold"];
	[ret addObject:@"Gold1"];
	[ret addObject:@"Gold2"];
	[ret addObject:@"Gold3"];
	[ret addObject:@"Goldenrod4"];
	[ret addObject:@"Medium Goldenrod"];
	[ret addObject:@"Yellow Green1"];

	return ret;
}

#pragma mark Shades of Metal
	
+(NSMutableArray *)getRGBColorMetalList{
	NSMutableArray *ret=[NSMutableArray arrayWithCapacity:10];
	[ret addObject:@"Copper"];
	[ret addObject:@"Cool Copper"];
	[ret addObject:@"Green Copper"];
	[ret addObject:@"Brass"];
	[ret addObject:@"Bronze"];
	[ret addObject:@"Bronze II"];
	[ret addObject:@"Bright Gold"];
	[ret addObject:@"Old Gold"];
	[ret addObject:@"CSS Gold"];
	[ret addObject:@"Gold4"];
	[ret addObject:@"Silver"];
	[ret addObject:@"Silver_Grey"];
	[ret addObject:@"Light Steel Blue5"];
	[ret addObject:@"Steel Blue7"];
	
	return ret;
}

+(NSMutableArray *)getRGBColorGroupList{
	NSMutableArray *ret=[NSMutableArray arrayWithCapacity:2];
	[ret addObject:@"Grey"];
	[ret addObject:@"Blue"];
	[ret addObject:@"Brown"];
	[ret addObject:@"Green"];
	[ret addObject:@"Orange"];
	[ret addObject:@"Red"];
	[ret addObject:@"Violet"];
	[ret addObject:@"White"];
	[ret addObject:@"Yellow"];
	[ret addObject:@"Metal"];

	return ret;
}

//this method define a font color for each item color in a group if user used this item to make a background 
//to be ensured that the font color and background color have a contrast. 
+(UIColor *)fontColorForRGBGroupList:(NSInteger)groupList atItem:(NSInteger)row{
	switch (groupList){
		case blackGreyList:
			if(row==grey || row==black || row==grey1 || row== darkSlateGrey || row==dimGrey
			   ||row== freeSpeechGrey ||row==slateGray||row==grey2){
				return [UIColor whiteColor];
			}else {
				return [UIColor blackColor];
			}
			break;
		case blueList:
			if(row==blueViolet||row==cadetBlue||(row>=cornFlowerBlue1 && row<=darkSlateBlue)
			   ||(row>=deepSkyBlue2 && row<=dodgerBlue3)||row==lightBlue4||row==lightCyan3
			   ||row==lightSkyBlue4||row==lightSlateBlue||row==lightSteelBlue4||row==mediumBlue
			   ||row==mediumSlateBlue||row==midnightBlue||row==navyBlue||row==paleTurquoise3
			   ||(row>=royalBlue && row<=royalBlue4)||(row>=skyBlue3 && row<=steelBlue)
			   ||(row>=steelBlue2 && row<=steelBlue6)||row==aquamarine1||(row>=azure3 && row<=blue3)
			   ||(row>=cyan2 && row<=teal)||row==turquoise3||row==darkSlateGray
			   ||(row>=darkSlateGray3 && row<=slateBlue5)||row==freeSpeechBlue){
				return [UIColor whiteColor];
			}else {
				return [UIColor blackColor];
			}
			break;
		case brownList:
			if(row==rosyBrown4||row==saddleBrown||(row>=brown&&row<=brown4)||row==darkBrown
			   ||row==burlywood2||row==bakersChocolate||row==chocolate3||(row>=darkTan && row<=mediumWood)
			   ||row==sienna5||row==veryDarkBrown){
				return [UIColor whiteColor];
			}else {
				return [UIColor blackColor];
			}
			
			break;
		case greenList:
			if((row>=darkGreen && row<=darkgreencopper)||row==darkOliveGreen||row==lightSeaGreen||row==mediumSeaGreen
			   ||row==darkOliveGreen4 || row==olive ||row==darkSeaGreen3 ||row==forestGreen
			   ||row==oliveDrab||row==oliveDrab4||row==paleGreen2||row==seaGreen
			   ||row==springGreen1||(row>=chartreuse2 && row<=green1)||row==khaki2
			   ||row==darkOliveGreen5||row==hunterGreen||row==forestGreen1||row==mediumSeaGreen1
			   ||row==seaGreen3){
				return [UIColor whiteColor];
			}else {
				return [UIColor blackColor];
			}
			
			break;
		case orangeList:
			if(row==darkOrange1||row==darkOrange2||row==lightSalmon1||row==peachPuff3||row==bisque3
			   ||(row>=coral1&&row<=coral3)||row==honeydew3||row==orange2||row==orange3||(row>=salmon2&&row<=sienna)
			   ||(row>=sienna3&&row<=mandarianOrange)||row==orangeRed4){
				return [UIColor whiteColor];
			}else {
				return [UIColor blackColor];
			}
			
			break;
		case redList:
			if(row<=deepPink3||(row>=hotPink1 && row<=indianRed4)||row==lightPink3||row==mediumVioletRed
			   ||(row>=mistyRose3&&row<=orangeRed3)||(row>=paleVioletRed3 && row<=firebrick4)
			   ||row==pink3||(row>=red && row<=firebrick5)
			   ||(row>=pink4 && row<=freeSpeechRed)){
				return [UIColor whiteColor];
			}else {
				return [UIColor blackColor];
			}
			
			break;
		case violetList:
			if((row>=darkOrchid && row<=darkViolet)||(row>=lavenderBlush3//||(row>=mediumOrchid4
													  &&row<=mediumPurple4)||(row>=magenta && row<=maroon4)||row==orchid4
			   ||(row>=plum3 && row<=purple5||row==thistle4||row==violetblue||row==darkPurple
				  ||row==maroon6||row>=violet1)){
				return [UIColor whiteColor];
			}else {
				return [UIColor blackColor];
			}
			
			break;
		case whiteList:
			if(row==antiqueWhite4||row==navajoWhite3||row==ivory3||row==seashell3
			   ||row==snow3||row==wheat3){
				return [UIColor whiteColor];
			}else {
				return [UIColor blackColor];
			}
			
			break;
		case yellowList:
			if(row==darkGoldenrod||row==darkGoldenrod4||row==lemonChiffon3||row==lightGoldenrod3
			   ||row==lightYellow3||row==cornsilk3||row==goldenrod3||row==yellow2||row==gold3){
				return [UIColor whiteColor];
			}else {
				return [UIColor blackColor];
			}
			
			break;
		case metalList:
			if((row>= copper && row<=bronzeII) ||row==gold4||row>=lightSteelBlue5){
				return [UIColor whiteColor];
			}else {
				return [UIColor blackColor];
			}
			break;
	}
	return [UIColor blackColor];
}


+(UIColor *)colorForGroup:(NSInteger)groupID atIndex:(NSInteger)row{
	UIColor *ret;
	
	switch (groupID){
		case blackGreyList:
			ret=[RGBColor RGBColorBlackGreyByIndex:row];
			break;
		case blueList:
			ret=[RGBColor RGBColorBlueByIndex:row];
			break;
		case brownList:
			ret=[RGBColor RGBColorBrownByIndex:row];
			break;
		case greenList:
			ret=[RGBColor RGBColorGreenByIndex:row];
			break;
		case orangeList:
			ret=[RGBColor RGBColorOrangeByIndex:row];
			break;
		case redList:
			ret=[RGBColor RGBColorRedByIndex:row];
			break;
		case violetList:
			ret=[RGBColor RGBColorVioletByIndex:row];
			break;
		case whiteList:
			ret=[RGBColor RGBColorWhiteByIndex:row];
			break;
		case yellowList:
			ret=[RGBColor RGBColorYellowByIndex:row];
			break;
		case metalList:
			ret=[RGBColor RGBColorMetalByIndex:row];
			break;
	}
	
	return ret;
}
@end
