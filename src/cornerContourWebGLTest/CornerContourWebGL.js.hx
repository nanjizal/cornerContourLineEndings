package cornerContourWebGLTest;

import cornerContour.io.Float32Array;

// contour code
import cornerContour.Sketcher;
import cornerContour.SketcherGrad;
import cornerContour.IPen;
import cornerContour.Pen2D;
import cornerContour.Pen2DGrad;
import cornerContour.StyleSketch;
import cornerContour.StyleEndLine;
// SVG path parser
import justPath.*;
import justPath.transform.ScaleContext;
import justPath.transform.ScaleTranslateContext;
import justPath.transform.TranslationContext;

// webgl gl stuff
import cornerContourWebGLTest.ShaderColor2D;
import cornerContourWebGLTest.HelpGL;
import cornerContourWebGLTest.BufferGL;
import cornerContourWebGLTest.GL;

// html stuff
import cornerContourWebGLTest.Sheet;
import cornerContourWebGLTest.DivertTrace;

// js webgl 
import js.html.webgl.Buffer;
import js.html.webgl.RenderingContext;
import js.html.webgl.Program;
import js.html.webgl.Texture;


function main(){
    new CornerContourWebGL();
}

class CornerContourWebGL {
    
    // -D gradientTest used in compile.hxml to change to and from gradients.
    
    // Test lineEnd styles here
    //public var styleEnd = StyleEndLine.no;
    //public var styleEnd = StyleEndLine.begin;
    //public var styleEnd = StyleEndLine.end;
    //public var styleEnd = StyleEndLine.both;
    //public var styleEnd = StyleEndLine.halfRound;
    public var styleEnd = StyleEndLine.quadrant;
    //public var styleEnd = StyleEndLine.triangleBegin;
    //public var styleEnd = StyleEndLine.triangleEnd;
    //public var styleEnd = StyleEndLine.triangleBoth;
    //public var styleEnd = StyleEndLine.arrowBegin;
    //public var styleEnd = StyleEndLine.arrowEnd;
    //public var styleEnd = StyleEndLine.arrowBoth;
    //
    
    
    // cornerContour specific code
    //var sketcher:       Sketcher;//Grad;
    //var pen2D:          Pen2D;//Grad;
    
    #if gradientTest
    var sketcher:       SketcherGrad;
    var pen2D:          Pen2DGrad;
    #else
    var sketcher:       Sketcher;
    var pen2D:          Pen2D;
    #end
    
    
    var quadtest_d      = "M200,300 Q400,50 600,300 T1000,300";
    var cubictest_d     = "M100,200 C100,100 250,100 250,200S400,300 400,200";
    
    // WebGL/Html specific code
    public var gl:               RenderingContext;
        // general inputs
    final vertexPosition         = 'vertexPosition';
    final vertexColor            = 'vertexColor';

    // general
    public var width:            Int;
    public var height:           Int;
    public var mainSheet:        Sheet;

    // Color
    public var programColor:     Program;
    public var bufColor:         Buffer;
    var divertTrace:             DivertTrace;
    var arr32:                   Float32Array;
    var len:                     Int;
    var totalTriangles:          Int;
    var bufferLength:            Int;
    public function new(){
        divertTrace = new DivertTrace();
        trace('Contour Test');
        width = 1024;
        height = 768;
        // use Pen to draw to Array
        drawContours();
        rearrageDrawData();
        renderOnce();
    }
  #if gradientTest
    public
    function rearrageDrawData(){
        trace( 'rearrangeDrawData' );
        var pen = pen2D;
        //trace( pen );
        var data = pen.arr;
        var redA    = 0.;   
        var greenA  = 0.;
        var blueA   = 0.; 
        var alphaA  = 0.;
        var colorA: Int  = 0;
        var redB    = 0.;   
        var greenB  = 0.;
        var blueB   = 0.; 
        var alphaB  = 0.;
        var colorB: Int  = 0;
        var redC    = 0.;   
        var greenC  = 0.;
        var blueC   = 0.; 
        var alphaC  = 0.;
        var colorC: Int  = 0;
        // triangle length
        totalTriangles = Std.int( data.size/9 );//7
        bufferLength = totalTriangles*3;
         // xy rgba = 6
        len = Std.int( totalTriangles * 6 * 3 );//6
        var j = 0;
        arr32 = new Float32Array( len );
        trace('total triangles ' + len );
        for( i in 0...totalTriangles ){
            pen.pos = i;
            
            colorA = Std.int( data.colorA );
            
            alphaA = alphaChannel( colorA );
            redA   = redChannel(   colorA );
            greenA = greenChannel( colorA );
            blueA  = blueChannel(  colorA );
            
            colorB = Std.int( data.colorB );
            
            alphaB = alphaChannel( colorB );
            redB   = redChannel(   colorB );
            greenB = greenChannel( colorB );
            blueB  = blueChannel(  colorB );
            
            colorC = Std.int( data.colorC );
            
            alphaC = alphaChannel( colorC );
            redC   = redChannel(   colorC );
            greenC = greenChannel( colorC );
            blueC  = blueChannel(  colorC );
            
            // populate arr32.
            arr32[ j ] = gx( data.ax );
            j++;
            arr32[ j ] = gy( data.ay );
            j++;
            arr32[ j ] = redA;
            j++;
            arr32[ j ] = greenA;
            j++;
            arr32[ j ] = blueA;
            j++;
            arr32[ j ] = alphaA;
            j++;
            arr32[ j ] = gx( data.bx );
            j++;
            arr32[ j ] = gy( data.by );
            j++;
            arr32[ j ] = redB;
            j++;
            arr32[ j ] = greenB;
            j++;
            arr32[ j ] = blueB;
            j++;
            arr32[ j ] = alphaB;
            j++;
            arr32[ j ] = gx( data.cx );
            j++;
            arr32[ j ] = gy( data.cy );
            j++;
            arr32[ j ] = redC;
            j++;
            arr32[ j ] = greenC;
            j++;
            arr32[ j ] = blueC;
            j++;
            arr32[ j ] = alphaC;
            j++;
        }
    }
  #else
    public
    function rearrageDrawData(){
      trace( 'rearrangeDrawData' );
      var pen = pen2D;
      var data = pen.arr;
      var red    = 0.;   
      var green  = 0.;
      var blue   = 0.; 
      var alpha  = 0.;
      var color: Int  = 0;
      // triangle length
      totalTriangles = Std.int( data.size/7 );
      bufferLength = totalTriangles*3;
       // xy rgba = 6
      len = Std.int( totalTriangles * 6 * 3 );
      var j = 0;
      arr32 = new Float32Array( len );
      for( i in 0...totalTriangles ){
          pen.pos = i;
          color = Std.int( data.color );
          alpha = alphaChannel( color );
          red   = redChannel(   color );
          green = greenChannel( color );
          blue  = blueChannel(  color );
          // populate arr32.
          arr32[ j ] = gx( data.ax );
          j++;
          arr32[ j ] = gy( data.ay );
          j++;
          arr32[ j ] = red;
          j++;
          arr32[ j ] = green;
          j++;
          arr32[ j ] = blue;
          j++;
          arr32[ j ] = alpha;
          j++;
          arr32[ j ] = gx( data.bx );
          j++;
          arr32[ j ] = gy( data.by );
          j++;
          arr32[ j ] = red;
          j++;
          arr32[ j ] = green;
          j++;
          arr32[ j ] = blue;
          j++;
          arr32[ j ] = alpha;
          j++;
          arr32[ j ] = gx( data.cx );
          j++;
          arr32[ j ] = gy( data.cy );
          j++;
          arr32[ j ] = red;
          j++;
          arr32[ j ] = green;
          j++;
          arr32[ j ] = blue;
          j++;
          arr32[ j ] = alpha;
          j++;
      }
    }
  #end
    public
    function drawContours(){
        trace( 'drawContours' );
        //pen2D = new Pen2D( 0xFF000000 ); //Grad( 0xFF0000FF, 0xFF00FF00, 0xFF0000FF );
        
    #if gradientTest
        pen2D = new Pen2DGrad( 0xFF0000FF, 0xFF00FF00, 0xFF0000FF );
        //arcSVG();
        pen2D.currentColor = 0xFF0000FF;
        pen2D.colorB = 0xFF00FF00;
        pen2D.colorC = 0xFF0000FF;
    #else 
        pen2D = new Pen2D( 0xFF000000 );
    #end
        //randomTest();
        //lineTest();
        //birdSVG();
        //cubicSVG();
        //quadSVG();
        
        turtleTest0( 150. + Std.random(200), 150. + Std.random(200) );
        pen2D.currentColor = 0xFF000000 + Std.random( 0xFFFFFF );
    #if gradientTest
        pen2D.colorB = 0xFF000000 + Std.random( 0xFFFFFF );
    #end
        turtleTest1( 150. + Std.random(200), 150. + Std.random(200) );
        pen2D.currentColor = 0xFF000000 + Std.random( 0xFFFFFF );
    #if gradientTest
        pen2D.colorB = 0xFF000000 + Std.random( 0xFFFFFF );
    #end
        turtleTest2( 150. + Std.random(200), 150. + Std.random(200) );
        pen2D.currentColor = 0xFF000000 + Std.random( 0xFFFFFF );
    #if gradientTest
        pen2D.colorB = 0xFF000000 + Std.random( 0xFFFFFF );
    #end
        turtleTest3( 150. + Std.random(200), 150. + Std.random(200) );
        pen2D.currentColor = 0xFF000000 + Std.random( 0xFFFFFF );
    #if gradientTest
        pen2D.colorB = 0xFF000000 + Std.random( 0xFFFFFF );
    #end
        turtleTest4( 150. + Std.random(200), 150. + Std.random(200) );
        pen2D.currentColor = 0xFF000000 + Std.random( 0xFFFFFF );
    #if gradientTest
        pen2D.colorB = 0xFF000000 + Std.random( 0xFFFFFF );
    #end
        turtleTest5( 150. + Std.random(200), 150. + Std.random(200) );
        pen2D.currentColor = 0xFF000000 + Std.random( 0xFFFFFF );
    #if gradientTest
        pen2D.colorB = 0xFF000000 + Std.random( 0xFFFFFF );
    #end
        turtleTest6( 150. + Std.random(200), 150. + Std.random(200) );
        pen2D.currentColor = 0xFF000000 + Std.random( 0xFFFFFF );
    #if gradientTest
        pen2D.colorB = 0xFF000000 + Std.random( 0xFFFFFF );
    #end
        turtleTest7( 150. + Std.random(200), 150. + Std.random(200) );
        
    }
    public
    function randomTest(){
    #if gradientTest
        var sketcher = new SketcherGrad( pen2D, StyleSketch.Fine, styleEnd );
    #else
        var sketcher = new Sketcher( pen2D, StyleSketch.Fine, styleEnd );
    #end
        sketcher.width = 20;
        sketcher.moveTo( 40, 100 );
        for( i in 0...100 ){
            randomDraw( sketcher, pen2D );
        }
    }
    public function randomDraw( s: Sketcher, p: IPen ){
        var n = Std.random(3);
        switch( n ){
            case 0:
                s.lineTo( 10 + 500*Math.random(),10+ 500*Math.random() );
            case 1:
                s.quadTo( 10+500*Math.random(),10+500*Math.random(), 10+500*Math.random(),10+500*Math.random() );
            case 2:
                var max = 0xFFFFFF;
                p.currentColor = 0xFF000000 + Std.random( max );
                if( p.currentColor == 0xFF000000 ) p.currentColor = 0xFFff0000;
    #if gradientTest
                p.colorB =  0xFF000000 + Std.random( max );
    #end
        }
    }
    
    public
    function renderOnce(){
        trace( 'renderOnce' );
        //return;
        mainSheet = new Sheet();
        mainSheet.create( width, height, true );
        gl = mainSheet.gl;
        clearAll( gl, width, height, 0., 0., 0., 1. );
        programColor = programSetup( gl, vertexString, fragmentString );
        gl.bindBuffer( GL.ARRAY_BUFFER, null );
        gl.useProgram( programColor );
        bufColor = interleaveXY_RGBA( gl
                       , programColor
                       , arr32
                       , vertexPosition, vertexColor, true );
        gl.bindBuffer( GL.ARRAY_BUFFER, bufColor );
        gl.useProgram( programColor );
        gl.drawArrays( GL.TRIANGLES, 0, bufferLength );
        
    }
    public static inline
    function alphaChannel( int: Int ) : Float
        return ((int >> 24) & 255) / 255;
    public static inline
    function redChannel( int: Int ) : Float
        return ((int >> 16) & 255) / 255;
    public static inline
    function greenChannel( int: Int ) : Float
        return ((int >> 8) & 255) / 255;
    public static inline
    function blueChannel( int: Int ) : Float
        return (int & 255) / 255;
    public inline
    function gx( v: Float ): Float {
        return -( 1 - 2*v/width );
    }
    public inline
    function gy( v: Float ): Float {
        return ( 1 - 2*v/height );
    }
    public
    function lineTest(){
        #if gradientTest
            var sketcher = new SketcherGrad( pen2D, StyleSketch.Fine, styleEnd );
        #else
            var sketcher = new Sketcher( pen2D, StyleSketch.Fine, styleEnd );
        #end
        //var sketcher = new Sketcher( pen2D, StyleSketch.Fine, StyleEndLine.both );
        sketcher.width = 50;
        sketcher.moveTo( 40, 100 );
        sketcher.lineTo( 100, 100 );
        sketcher.lineTo( 120, 300 );
        sketcher.moveTo( 300, 100 );
        sketcher.moveTo( 300, 100 );
        sketcher.lineTo( 380, 100 );
        sketcher.lineTo( 350, 0 );
        //turtleTest8();
    }
    public
    function turtleTest8( x: Float, y: Float ){
        #if gradientTest
            var sketcher = new SketcherGrad( pen2D, StyleSketch.Fine, styleEnd ) ;
        #else
            var sketcher = new Sketcher( pen2D, StyleSketch.Fine, styleEnd );
        #end
        sketcher.setPosition( x, y )
            .penSize( 50 )
            .right( 90 )
            .forward( 100 )
            .right( 120 )
            .forward( 70 )
            .arc( 50, 120 );
            sketcher.moveTo( 50, 120 ); // makes it draw end
    }
    public
    function turtleTest0(x: Float, y: Float ){
        #if gradientTest
            var sketcher = new SketcherGrad( pen2D, StyleSketch.Fine, styleEnd ) ;
        #else
            var sketcher = new Sketcher( pen2D, StyleSketch.Fine, styleEnd );
        #end
        sketcher.setPosition( x, y )
            .penSize( 30 )
            .forward( 60 )
            .right( 45 )
            .forward( 60 )
            .right( 45 )
            .forward( 70 )
            .arc( 50, 120 );
            var p = sketcher.position();
            sketcher.moveTo( p.x, p.y ); // makes it draw end
    }
    public
    function turtleTest1(x: Float, y: Float ){
        #if gradientTest
            var sketcher = new SketcherGrad( pen2D, StyleSketch.Fine, styleEnd ) ;
        #else
            var sketcher = new Sketcher( pen2D, StyleSketch.Fine, styleEnd );
        #end
        sketcher.setPosition( x, y )
            .penSize( 30 )
            .right( 90 )
            .forward( 60 )
            .left( 45 )
            .forward( 70 )
            .arc( 50, 120 )
            .left( 50 )
            .forward( 70 )
            .forward( 10 );
            var p = sketcher.position();
            sketcher.moveTo( p.x+1, p.y+1 ); // makes it draw end
    }
    public
    function turtleTest2(x: Float, y: Float ){
        #if gradientTest
            var sketcher = new SketcherGrad( pen2D, StyleSketch.Fine, styleEnd ) ;
        #else
            var sketcher = new Sketcher( pen2D, StyleSketch.Fine, styleEnd );
        #end
        sketcher.setPosition( x, y )
            .penSize( 30 )
            .left( 90 )
            .forward( 60 )
            .right( 45 )
            .forward( 70 )
            .arc( 50, 120 )
            .right( 50 )
            .forward( 70 );
            var p = sketcher.position();
            sketcher.moveTo( p.x, p.y ); // makes it draw end
    }
    public
    function turtleTest3(x: Float, y: Float ){
        #if gradientTest
            var sketcher = new SketcherGrad( pen2D, StyleSketch.Fine, styleEnd ) ;
        #else
            var sketcher = new Sketcher( pen2D, StyleSketch.Fine, styleEnd );
        #end
        sketcher.setPosition( x, y )
            .penSize( 30 )
            .left( 90 )
            .forward( 60 )
            .right( 45 )
            .forward( 70 )
            .arc( 50, 120 )
            .left( 50 )
            .forward( 70 );
            var p = sketcher.position();
            sketcher.moveTo( p.x, p.y ); // makes it draw end
    }
    public
    function turtleTest4(x: Float, y: Float ){
        #if gradientTest
            var sketcher = new SketcherGrad( pen2D, StyleSketch.Fine, styleEnd ) ;
        #else
            var sketcher = new Sketcher( pen2D, StyleSketch.Fine, styleEnd );
        #end
        sketcher.setPosition( x, y )
            .penSize( 30 )
            .left( 90 )
            .forward( 60 )
            .left( 45 )
            .forward( 70 )
            .arc( 50, 120 )
            .left( 50 )
            .forward( 70 );
            var p = sketcher.position();
            sketcher.moveTo( p.x, p.y ); // makes it draw end
    }
    public
    function turtleTest5(x: Float, y: Float ){
        #if gradientTest
            var sketcher = new SketcherGrad( pen2D, StyleSketch.Fine, styleEnd ) ;
        #else
            var sketcher = new Sketcher( pen2D, StyleSketch.Fine, styleEnd );
        #end
        sketcher.setPosition( x, y )
            .penSize( 30 )
            .left( 180 )
            .forward( 60 )
            .left( 45 )
            .forward( 70 )
            .arc( 50, 120 )
            .left( 50 )
            .forward( 70 );
            var p = sketcher.position();
            sketcher.moveTo( p.x, p.y ); // makes it draw end
    }
    public
    function turtleTest6(x: Float, y: Float ){
        #if gradientTest
            var sketcher = new SketcherGrad( pen2D, StyleSketch.Fine, styleEnd ) ;
        #else
            var sketcher = new Sketcher( pen2D, StyleSketch.Fine, styleEnd );
        #end
        sketcher.setPosition( x, y )
            .penSize( 30 )
            .left( 180 )
            .forward( 60 )
            .right( 45 )
            .forward( 70 )
            .arc( 50, 120 )
            .left( 50 )
            .forward( 70 );
            var p = sketcher.position();
            sketcher.moveTo( p.x, p.y ); // makes it draw end
    }
    public
    function turtleTest7(x: Float, y: Float ){
        #if gradientTest
            var sketcher = new SketcherGrad( pen2D, StyleSketch.Fine, styleEnd ) ;
        #else
            var sketcher = new Sketcher( pen2D, StyleSketch.Fine, styleEnd );
        #end
        sketcher.setPosition( x, y )
            .penSize( 30 )
            .left( 180 )
            .forward( 60 )
            .right( 45 )
            .forward( 70 )
            .arc( 50, 120 )
            .right( 50 )
            .forward( 70 );
            var p = sketcher.position();
            sketcher.moveTo( p.x, p.y ); // makes it draw end
    }
    /**
     * draws Kiwi svg
     */
    public
    function birdSVG(){
        #if gradientTest
            var sketcher = new SketcherGrad( pen2D, StyleSketch.Fine, styleEnd ) ;
        #else
            var sketcher = new Sketcher( pen2D, StyleSketch.Fine, styleEnd );
        #end
        //var sketcher = new Sketcher( pen2D, StyleSketch.Fine, StyleEndLine.both );
        sketcher.width = 10;
        var scaleTranslateContext = new ScaleTranslateContext( sketcher, 20, 0, 1, 1 );
        var p = new SvgPath( scaleTranslateContext );
        p.parse( bird_d );
    }
    /** 
     * draws cubic SVG
     */
    public
    function cubicSVG(){
        #if gradientTest
            var sketcher = new SketcherGrad( pen2D, StyleSketch.Fine, styleEnd ) ;
        #else
            var sketcher = new SketcherGrad( pen2D, StyleSketch.Fine, styleEnd );
        #end
        
        sketcher.width = 50;
        // function to adjust color of curve along length
        sketcher.colourFunction = function( colour: Int, x: Float, y: Float, x_: Float, y_: Float ):  Int {
            return Math.round( colour-1*x*y );
        }
    #if gradientTest
        sketcher.colourFunctionB = function( colour: Int, x: Float, y: Float, x_: Float, y_: Float ):  Int {
            return Math.round( colour+x/y );
        }
    #end
        var translateContext = new TranslationContext( sketcher, 50, 200 );
        var p = new SvgPath( translateContext );
        p.parse( cubictest_d );
    }
    /**
     * draws quad SVG
     */
    public
    function quadSVG(){
        #if gradientTest
            var sketcher = new SketcherGrad( pen2D, StyleSketch.Fine, styleEnd ) ;
        #else
            var sketcher = new Sketcher( pen2D, StyleSketch.Fine, styleEnd );
        #end
        //var sketcher = new Sketcher( pen2D, StyleSketch.Fine, StyleEndLine.both );
        
        sketcher.width = 1;
        // function to adjust width of curve along length
        sketcher.widthFunction = function( width: Float, x: Float, y: Float, x_: Float, y_: Float ): Float{
            return width+0.008*2;
        }
        var translateContext = new ScaleTranslateContext( sketcher, 0, 100, 0.5, 0.5 );
        var p = new SvgPath( translateContext );
        p.parse( quadtest_d );
    }
    /**
     * draws elipse arcs
     */
    public
    function arcSVG(){
        var arcs0  = [ arc0_0, arc0_1, arc0_2, arc0_3 ];
        var arcs1  = [ arc1_0, arc1_1, arc1_2, arc1_3 ];
        var arcs2  = [ arc2_0, arc2_1, arc2_2, arc2_3 ];
        var arcs3  = [ arc3_0, arc3_1, arc3_2, arc3_3 ];
        var arcs4  = [ arc4_0, arc4_1, arc4_2, arc4_3 ];
        var arcs5  = [ arc5_0, arc5_1, arc5_2, arc5_3 ];
        var arcs6  = [ arc6_0, arc6_1, arc6_2, arc6_3 ];
        var arcs7  = [ arc7_0, arc7_1, arc7_2, arc7_3 ];
        var pallet = [ silver, gainsboro, lightGray, crimson ];
        var x0 = 130;
        var x1 = 450;
        var yPos = [ -30, 100, 250, 400 ];
        var arcs = [ arcs0, arcs1, arcs2, arcs3, arcs4, arcs5, arcs6, arcs7 ];
        for( i in 0...yPos.length ){
            drawSet( arcs.shift(), pallet, x0, yPos[i], 0.5 );
            drawSet( arcs.shift(), pallet, x1, yPos[i], 0.5 );
        }
    }
    // draws a set of svg ellipses.
    function drawSet( arcs: Array<String>, col:Array<Int>, x: Float, y: Float, s: Float ){    
        for( i in 0...arcs.length ) draw_d( arcs[ i ], x, y, s, 10., col[ i ] );
    }
    // draws an svg ellipse
    function draw_d( d: String, x: Float, y: Float, s: Float, w: Float, color: Int ){
        pen2D.currentColor = color;
        #if gradientTest
            var sketcher = new SketcherGrad( pen2D, StyleSketch.Fine, styleEnd ) ;
        #else
            var sketcher = new Sketcher( pen2D, StyleSketch.Fine, styleEnd );
        #end
        sketcher.width = w;
        var trans = new ScaleTranslateContext( sketcher, x, y, s, s );
        var p = new SvgPath( trans );
        p.parse( d );
    }
    
    // elipses
    var crimson     = 0xFFDC143C;
    var silver      = 0xFFC0C0C0;
    var gainsboro   = 0xFFDCDCDC;
    var lightGray   = 0xFFD3D3D3;
    var arc0_0      = "M 100 200 A 100 50 0.0 0 1 250 150";
    var arc0_1      = "M 100 200 A 100 50 0.0 1 0 250 150";
    var arc0_2      = "M 100 200 A 100 50 0.0 1 1 250 150";
    var arc0_3      = "M 100 200 A 100 50 0.0 0 0 250 150";
    var arc1_0      = "M 100 200 A 100 50 0.0 0 0 250 150";
    var arc1_1      = "M 100 200 A 100 50 0.0 1 0 250 150";
    var arc1_2      = "M 100 200 A 100 50 0.0 1 1 250 150";
    var arc1_3      = "M 100 200 A 100 50 0.0 0 1 250 150";
    var arc2_0      = "M 100 200 A 100 50 -15 0 0 250 150";
    var arc2_1      = "M 100 200 A 100 50 -15 0 1 250 150";
    var arc2_2      = "M 100 200 A 100 50 -15 1 1 250 150";
    var arc2_3      = "M 100 200 A 100 50 -15 1 0 250 150";
    var arc3_0      = "M 100 200 A 100 50 -15 0 0 250 150";
    var arc3_1      = "M 100 200 A 100 50 -15 0 1 250 150";
    var arc3_2      = "M 100 200 A 100 50 -15 1 0 250 150";
    var arc3_3      = "M 100 200 A 100 50 -15 1 1 250 150";
    var arc4_0      = "M 100 200 A 100 50 -44 1 0 250 150";
    var arc4_1      = "M 100 200 A 100 50 -44 0 1 250 150";
    var arc4_2      = "M 100 200 A 100 50 -44 1 1 250 150";
    var arc4_3      = "M 100 200 A 100 50 -44 0 0 250 150";
    var arc5_0      = "M 100 200 A 100 50 -44 0 0 250 150";
    var arc5_1      = "M 100 200 A 100 50 -44 1 1 250 150";
    var arc5_2      = "M 100 200 A 100 50 -44 1 0 250 150";
    var arc5_3      = "M 100 200 A 100 50 -44 0 1 250 150";
    var arc6_0      = "M 100 200 A 100 50 -45 0 0 250 150";
    var arc6_1      = "M 100 200 A 100 50 -45 0 1 250 150";
    var arc6_2      = "M 100 200 A 100 50 -45 1 1 250 150";
    var arc6_3      = "M 100 200 A 100 50 -45 1 0 250 150";
    var arc7_0      = "M 100 200 A 100 50 -45 0 0 250 150";
    var arc7_1      = "M 100 200 A 100 50 -45 0 1 250 150";
    var arc7_2      = "M 100 200 A 100 50 -45 1 0 250 150";
    var arc7_3      = "M 100 200 A 100 50 -45 1 1 250 150";
    

    // kiwi bird
    var bird_d = "M210.333,65.331C104.367,66.105-12.349,150.637,1.056,276.449c4.303,40.393,18.533,63.704,52.171,79.03c36.307,16.544,57.022,54.556,50.406,112.954c-9.935,4.88-17.405,11.031-19.132,20.015c7.531-0.17,14.943-0.312,22.59,4.341c20.333,12.375,31.296,27.363,42.979,51.72c1.714,3.572,8.192,2.849,8.312-3.078c0.17-8.467-1.856-17.454-5.226-26.933c-2.955-8.313,3.059-7.985,6.917-6.106c6.399,3.115,16.334,9.43,30.39,13.098c5.392,1.407,5.995-3.877,5.224-6.991c-1.864-7.522-11.009-10.862-24.519-19.229c-4.82-2.984-0.927-9.736,5.168-8.351l20.234,2.415c3.359,0.763,4.555-6.114,0.882-7.875c-14.198-6.804-28.897-10.098-53.864-7.799c-11.617-29.265-29.811-61.617-15.674-81.681c12.639-17.938,31.216-20.74,39.147,43.489c-5.002,3.107-11.215,5.031-11.332,13.024c7.201-2.845,11.207-1.399,14.791,0c17.912,6.998,35.462,21.826,52.982,37.309c3.739,3.303,8.413-1.718,6.991-6.034c-2.138-6.494-8.053-10.659-14.791-20.016c-3.239-4.495,5.03-7.045,10.886-6.876c13.849,0.396,22.886,8.268,35.177,11.218c4.483,1.076,9.741-1.964,6.917-6.917c-3.472-6.085-13.015-9.124-19.18-13.413c-4.357-3.029-3.025-7.132,2.697-6.602c3.905,0.361,8.478,2.271,13.908,1.767c9.946-0.925,7.717-7.169-0.883-9.566c-19.036-5.304-39.891-6.311-61.665-5.225c-43.837-8.358-31.554-84.887,0-90.363c29.571-5.132,62.966-13.339,99.928-32.156c32.668-5.429,64.835-12.446,92.939-33.85c48.106-14.469,111.903,16.113,204.241,149.695c3.926,5.681,15.819,9.94,9.524-6.351c-15.893-41.125-68.176-93.328-92.13-132.085c-24.581-39.774-14.34-61.243-39.957-91.247c-21.326-24.978-47.502-25.803-77.339-17.365c-23.461,6.634-39.234-7.117-52.98-31.273C318.42,87.525,265.838,64.927,210.333,65.331zM445.731,203.01c6.12,0,11.112,4.919,11.112,11.038c0,6.119-4.994,11.111-11.112,11.111s-11.038-4.994-11.038-11.111C434.693,207.929,439.613,203.01,445.731,203.01z";
    
}