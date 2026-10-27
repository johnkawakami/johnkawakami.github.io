port module Main exposing (..)

import Browser
import Editor
import Home
import Html exposing (Html, button, div, main_, nav, section, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Message
import Search
import User

type Tab
    = Home
    | Editor
    | Message
    | Search
    | User

type alias Model =
    { activeTab : Tab
    }

init : () -> ( Model, Cmd Msg )
init _ =
    ( { activeTab = Home }, Cmd.none )

type Msg
    = TabClicked Tab
    | ToggleDarkMode

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TabClicked tab ->
            ( { model | activeTab = tab }, Cmd.none )

        ToggleDarkMode ->
            ( model, toggleDarkMode () )


port toggleDarkMode : () -> Cmd msg

view : Model -> Html Msg
view model =
    div []
        [ main_ [ class "spa-container" ]
            [ viewSpa model.activeTab
            ]
        , nav [ class "tab-bar" ]
            [ tabButton model.activeTab Home "🏠"
            , tabButton model.activeTab Editor "✏️"
            , tabButton model.activeTab Message "💬"
            , tabButton model.activeTab Search "🔍"
            , tabButton model.activeTab User "👤"
            ]
        ]

viewSpa : Tab -> Html Msg
viewSpa active =
    div []
        [ section
            [ classList [ ( "spa", True ), ( "active", active == Home ) ] ]
            [ Html.map (\_ -> TabClicked Home) Home.view ]
        , section
            [ classList [ ( "spa", True ), ( "active", active == Editor ) ] ]
            [ Editor.view ]
        , section
            [ classList [ ( "spa", True ), ( "active", active == Message ) ] ]
            [ Html.map (\_ -> TabClicked Message) Message.view ]
        , section
            [ classList [ ( "spa", True ), ( "active", active == Search ) ] ]
            [ Search.view ]
        , section
            [ classList [ ( "spa", True ), ( "active", active == User ) ] ]
            [ Html.map (\_ -> ToggleDarkMode) User.view ]
        ]

tabButton : Tab -> Tab -> String -> Html Msg
tabButton active tab label =
    button
        [ classList
            [ ( "tab", True )
            , ( "active", active == tab )
            , ( "tab-middle", tab == Message )
            ]
        , onClick (TabClicked tab)
        , Html.Attributes.attribute "aria-label" (tabToLabel tab)
        ]
        [ text label ]

tabToLabel : Tab -> String
tabToLabel tab =
    case tab of
        Home ->
            "Home"

        Editor ->
            "Editor"

        Message ->
            "Message"

        Search ->
            "Search"

        User ->
            "User"

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
