module User exposing (view)

import Html exposing (Html, button, div, h1, h2, input, label, p, span, text)
import Html.Attributes exposing (class, for, id, style, type_)
import Html.Events exposing (onClick)


type Msg
    = ToggleDarkMode


view : Html Msg
view =
    div [ class "page-container" ]
        [ h1 [ class "page-title" ] [ text "User" ]
        , div [ class "profile-header" ]
            [ div [ class "profile-avatar" ] [ text "U" ]
            , div [ class "profile-info" ]
                [ div [ class "profile-username" ] [ text "johndoe" ]
                , p [ class "profile-bio" ] [ text "Software developer" ]
                ]
            ]
        , h2 [ class "settings-title" ] [ text "Settings" ]
        , div [ class "settings-list" ]
            [ div [ class "setting-row" ]
                [ span [ class "setting-label" ] [ text "Go invisible" ]
                , label [ class "toggle-switch" ]
                    [ input [ type_ "checkbox" ] []
                    , span [ class "toggle-slider" ] []
                    ]
                ]
            , div [ class "setting-row" ]
                [ span [ class "setting-label" ] [ text "Save my data to the server" ]
                , label [ class "toggle-switch" ]
                    [ input [ type_ "checkbox" ] []
                    , span [ class "toggle-slider" ] []
                    ]
                ]
            , div [ class "setting-row" ]
                [ span [ class "setting-label" ] [ text "Cyber shields" ]
                , label [ class "toggle-switch" ]
                    [ input [ type_ "checkbox" ] []
                    , span [ class "toggle-slider" ] []
                    ]
                ]
            , div [ class "setting-row" ]
                [ span [ class "setting-label" ] [ text "Right to Left text" ]
                , label [ class "toggle-switch" ]
                    [ input [ type_ "checkbox" ] []
                    , span [ class "toggle-slider" ] []
                    ]
                ]
            ]
        , div [ class "setting-row" ]
            [ span [ class "setting-label" ] [ text "Dark Mode" ]
            , label [ class "toggle-switch" ]
                [ input [ type_ "checkbox", id "dark-mode-toggle", onClick ToggleDarkMode ] []
                , span [ class "toggle-slider" ] []
                ]
            ]
        ]

