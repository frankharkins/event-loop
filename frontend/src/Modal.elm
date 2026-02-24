module Modal exposing (viewIcon, modal, Msg(..))

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Svg.Attributes as SvgAttr

import Carbon.Icons exposing (..)

type Msg = ToggleOpen

iconClass : String
iconClass = "w-[1lh] h-[1lh] cursor-pointer text-muted hover:text-body transition duration-100"

viewIcon : Html Msg
viewIcon =
  Carbon.Icons.help "Help" [ SvgAttr.class iconClass, onClick ToggleOpen ]

modal : Bool -> Html Msg
modal open =
  div
    [ classList
      [ ("opacity-0 invisible", not open)
      , ("absolute z-100 transition-all duration-250 top-0 left-0 w-screen h-screen bg-muted/50 flex justify-center items-center p-8", True)
      ]
    , onClick ToggleOpen
    ]
    [ div [ class "border-px border-title bg-bg p-8 rounded-[4px] max-w-[800px] max-h-full overflow-auto shadow-lg" ]
      [ h2 [ class "font-bold text-title mb-4" ] [ text "What is Event loop?" ]
      , p [] [ text """
                    Event loop is a todo list designed for asynchronous work,
                    inspired by JavaScript's event loop. To use it, simply add a
                    task and mark whether it's blocked (such as waiting for code
                    review). If the task at the top of the list isn't blocked,
                    work on it until it is. Then mark it as blocked and hit
                    "Space" to push it to the end of the queue and start the next
                    task.
                    """ ]
      , h2 [ class "font-bold text-title mt-10 mb-4" ] [ text "Keyboard shortcuts" ]
      , p [] [ text "Event loop works best with a keyboard" ]
      , keyboardShortcutTable
      , h2 [ class "font-bold text-title mt-10 mb-4" ] [ text "About" ]
      , p []
        [ text "Event loop is written in "
        , link "https://elm-lang.org/" "Elm"
        , text " and is open-source on "
        , link "https://github.com/frankharkins/event-loop/" "GitHub"
        , text ". Created by "
        , link "https://frankharkins.github.io/" "Frank Harkins"
        , text "."
        ]
      ]
    ]

link : String -> String -> Html msg
link url linkText =
  a [ href url, class "text-link underline" ] [ text linkText ]

keyboardShortcuts : List (String, String)
keyboardShortcuts =
  [ ("n", "Create new task")
  , ("b", "Toggle if the current task is blocked")
  , ("d", "Delete the current task")
  , ("Space", "Skip to next task")
  , ("h", "Open this help modal")
  ]

keyboardShortcutTable : Html msg
keyboardShortcutTable =
  table [ class "my-4" ] (
    [ tr [ class "text-title" ]
      [ td [] [ text "Key" ]
      , td [] [ text "Action" ]
      ]
    ] ++ (
    keyboardShortcuts |> List.map (\(key, action) ->
      tr []
      [ td [] [ span [ class "p-1 px-2 rounded-[4px] border border-muted-extra" ] [ text key ] ]
      , td [] [ text action ]
      ]
    )))
