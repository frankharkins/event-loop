module Carbon.Icons exposing (..)

import Html exposing (Html, text)
import Html.Attributes as Attr exposing (attribute, class)
import Svg exposing (svg)
import Svg.Attributes as SvgAttr exposing (..)

trashCan : String -> List (Svg.Attribute msg) -> Html msg
trashCan title attr =
  svg
    ([ SvgAttr.id "icon"
    , SvgAttr.viewBox "0 0 32 32"
    , SvgAttr.fill "currentColor"
    ] ++ attr)
    [ Svg.defs []
        [ Svg.style []
            [ text ".cls-1{fill:none;}" ]
        ]
    , Svg.title []
        [ text title ]
    , Svg.rect
        [ SvgAttr.x "12"
        , SvgAttr.y "12"
        , SvgAttr.width "2"
        , SvgAttr.height "12"
        ]
        []
    , Svg.rect
        [ SvgAttr.x "18"
        , SvgAttr.y "12"
        , SvgAttr.width "2"
        , SvgAttr.height "12"
        ]
        []
    , Svg.path
        [ SvgAttr.d "M4,6V8H6V28a2,2,0,0,0,2,2H24a2,2,0,0,0,2-2V8h2V6ZM8,28V8H24V28Z"
        ]
        []
    , Svg.rect
        [ SvgAttr.x "12"
        , SvgAttr.y "2"
        , SvgAttr.width "8"
        , SvgAttr.height "2"
        ]
        []
    , Svg.rect
        [ SvgAttr.id "_Transparent_Rectangle_"
        , Attr.attribute "data-name" "<Transparent Rectangle>"
        , SvgAttr.class "cls-1"
        , SvgAttr.width "32"
        , SvgAttr.height "32"
        ]
        []
    ]

errorOutline : String -> List (Svg.Attribute msg) -> Html msg
errorOutline title attr =
  svg
    ([ SvgAttr.id "icon"
    , SvgAttr.viewBox "0 0 32 32"
    , SvgAttr.fill "currentColor"
    ] ++ attr)
    [ Svg.defs []
        [ Svg.style []
            [ text " .cls-1 { fill: none; } " ]
        ]
    , Svg.rect
        [ SvgAttr.x "14.9004"
        , SvgAttr.y "7.2004"
        , SvgAttr.width "2.1996"
        , SvgAttr.height "17.5994"
        , SvgAttr.transform "translate(-6.6275 16.0001) rotate(-45)"
        ]
        []
    , Svg.path
        [ SvgAttr.d "M16,2A13.9138,13.9138,0,0,0,2,16,13.9138,13.9138,0,0,0,16,30,13.9138,13.9138,0,0,0,30,16,13.9138,13.9138,0,0,0,16,2Zm0,26A12,12,0,1,1,28,16,12.0353,12.0353,0,0,1,16,28Z"
        ]
        []
    , Svg.rect
        [ SvgAttr.id "_Transparent_Rectangle_"
        , Attr.attribute "data-name" " Transparent Rectangle "
        , SvgAttr.class "cls-1"
        , SvgAttr.width "32"
        , SvgAttr.height "32"
        ]
        []
    ]

chevronUpOutline : String -> List (Svg.Attribute msg) -> Html msg
chevronUpOutline title attr =
  svg
    ([ SvgAttr.id "icon"
    , SvgAttr.viewBox "0 0 32 32"
    , SvgAttr.fill "currentColor"
    ] ++ attr)
    [ Svg.defs []
        [ Svg.style []
            [ text " .cls-1 { fill: none; } " ]
        ]
    , Svg.polygon
        [ SvgAttr.points "9.4142 19.4142 16 12.8286 22.5858 19.4142 24 18 16 10 8 18 9.4142 19.4142"
        ]
        []
    , Svg.path
        [ SvgAttr.d "m30,16c0,7.7197-6.2803,14-14,14S2,23.7197,2,16,8.2803,2,16,2s14,6.2803,14,14Zm-26,0c0,6.6167,5.3833,12,12,12s12-5.3833,12-12-5.3833-12-12-12S4,9.3833,4,16Z"
        ]
        []
    , Svg.rect
        [ SvgAttr.id "_Transparent_Rectangle_"
        , Attr.attribute "data-name" "&lt;Transparent Rectangle&gt;"
        , SvgAttr.class "cls-1"
        , SvgAttr.width "32"
        , SvgAttr.height "32"
        ]
        []
    ]

chevronDownOutline : String -> List (Svg.Attribute msg) -> Html msg
chevronDownOutline title attr =
  svg
    ([ SvgAttr.id "icon"
    , SvgAttr.viewBox "0 0 32 32"
    , SvgAttr.fill "currentColor"
    ] ++ attr)
    [ Svg.defs []
        [ Svg.style []
            [ text " .cls-1 { fill: none; } " ]
        ]
    , Svg.polygon
        [ SvgAttr.points "9.4142 12.5858 16 19.1714 22.5858 12.5858 24 14 16 22 8 14 9.4142 12.5858"
        ]
        []
    , Svg.path
        [ SvgAttr.d "m30,16c0,7.7197-6.2803,14-14,14S2,23.7197,2,16,8.2803,2,16,2s14,6.2803,14,14Zm-26,0c0,6.6167,5.3833,12,12,12s12-5.3833,12-12-5.3833-12-12-12S4,9.3833,4,16Z"
        ]
        []
    , Svg.rect
        [ SvgAttr.id "_Transparent_Rectangle_"
        , Attr.attribute "data-name" "&lt;Transparent Rectangle&gt;"
        , SvgAttr.class "cls-1"
        , SvgAttr.width "32"
        , SvgAttr.height "32"
        ]
        []
    ]
