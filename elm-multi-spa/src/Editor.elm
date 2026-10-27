module Editor exposing (view)

import Html exposing (Html, div, input, text)
import Html.Attributes exposing (id, placeholder, style, type_, value)


view : Html msg
view =
    div [ style "width" "100%", style "height" "100%", style "display" "flex", style "flex-direction" "column", style "background" "#f5f5f5" ]
        [ input
            [ type_ "text"
            , placeholder "Untitled Document"
            , value ""
            , style "margin" "0"
            , style "padding" "1rem"
            , style "border" "none"
            , style "border-bottom" "1px solid #ddd"
            , style "font-size" "1.5rem"
            , style "font-weight" "600"
            , style "background" "#f5f5f5"
            , style "color" "#000"
            , style "outline" "none"
            ]
            []
        , div [ id "quill-editor", style "flex" "1", style "background" "#fff", style "color" "#000", style "border" "none" ] []
        ]
