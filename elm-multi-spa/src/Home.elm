module Home exposing (view)

import Html exposing (Html, button, div, h1, h2, input, li, text, ul)
import Html.Attributes exposing (class, id, placeholder, style, type_)


view : Html msg
view =
    div [ class "home-container" ]
        [ h1 [ class "page-title" ] [ text "Documents" ]
        , ul [ class "document-list" ]
            [ li [ class "document-item" ] [ text "MyDoc" ]
            , li [ class "document-item" ] [ text "Untitled Document" ]
            , li [ class "document-item" ] [ text "Report" ]
            , li [ class "document-item" ] [ text "Notes" ]
            , li [ class "document-item" ] [ text "Draft" ]
            , li [ class "document-item" ] [ text "Ideas" ]
            , li [ class "document-item" ] [ text "Todo" ]
            , li [ class "document-item" ] [ text "Meeting Notes" ]
            , li [ class "document-item" ] [ text "Project Plan" ]
            , li [ class "document-item" ] [ text "Budget" ]
            , li [ class "document-item" ] [ text "Recipe" ]
            , li [ class "document-item" ] [ text "Journal" ]
            ]
        , button [ class "fab", id "add-doc-btn" ] [ text "+" ]
        , div [ id "add-doc-dialog", class "dialog-overlay", style "display" "none" ]
            [ div [ class "dialog" ]
                [ h2 [] [ text "New Document" ]
                , input [ type_ "text", placeholder "Document title", id "new-doc-title" ] []
                , div [ class "dialog-actions" ]
                    [ button [ id "cancel-add" ] [ text "Cancel" ]
                    , button [ id "create-add" ] [ text "Create" ]
                    ]
                ]
            ]
        ]
