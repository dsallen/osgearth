/* osgEarth
 * Copyright 2025 Pelican Mapping
 * MIT License
 */
#include <osgEarth/Fill>

using namespace osgEarth;

//------------------------------------------------------------------------

Fill::Fill()
{
    init();
}

Fill::Fill( float r, float g, float b, float a )
{
    init();
    _color.set( r, g, b, a );
}

Fill::Fill(const Color& color)
{
    init();
    _color = color;
}

Fill::Fill(StringExpression expr)
{
   init();
   _expr = expr;
}

Fill::Fill(const Config& conf )
{
    init();
    mergeConfig(conf);
}

Fill::Fill(const Fill& rhs)
{
    init();
    mergeConfig(rhs.getConfig());
}

void
Fill::init()
{
    _color.set( 1.0f, 1.0f, 1.0f, 1.0f );
    _expr.init(StringExpression(std::string("")));
}

Config
Fill::getConfig() const
{
    Config conf("fill");
    conf.add("color", _color.toHTML() );

    if( _expr.isSet() )
       conf.add("color_expr", _expr.get().expr() );
    return conf;
}

void
Fill::mergeConfig( const Config& conf )
{
    _color = Color( conf.value("color") );
   if( conf.hasValue("color_expr"))
       _expr = StringExpression(conf.value("color_expr"));
}
