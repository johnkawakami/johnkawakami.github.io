module Search exposing (view)

import Html exposing (Html, div, h1, input, li, span, text, ul)
import Html.Attributes exposing (class, placeholder, type_, value)


view : Html msg
view =
    div [ class "page-container" ]
        [ h1 [ class "page-title" ] [ text "Search" ]
        , input [ type_ "text", value "elm", placeholder "Search...", class "search-input" ] []
        , ul [ class "search-history" ]
            [ li [ class "search-history-item" ]
                [ span [ class "search-icon" ] [ text "🕒" ]
                , span [] [ text "elm tutorial" ]
                ]
            , li [ class "search-history-item" ]
                [ span [ class "search-icon" ] [ text "🕒" ]
                , span [] [ text "javascript" ]
                ]
            , li [ class "search-history-item" ]
                [ span [ class "search-icon" ] [ text "🕒" ]
                , span [] [ text "css flexbox" ]
                ]
            ]
        ]

