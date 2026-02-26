module EventCreator exposing (Msg(..), DraftEvent, view, emptyDraft, textInputId)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onCheck, onSubmit, onClick)

type Msg
  = CreateEvent DraftEvent
  | UpdateDraft DraftEvent
  | Expand
  | Hide

type alias DraftEvent =
  { name: String
  , isBlocked: Bool
  }

textInputId : String
textInputId = "event-creator-input"

emptyDraft : DraftEvent
emptyDraft =
  { name = ""
  , isBlocked = False
  }

mainInputClass : String
mainInputClass = "w-full border-1 border-muted-extra p-2 my-4 rounded-[4px] cursor-pointer hover:border-muted hover:bg-muted-extra ease-out duration-100 accent-cursor"

buttonClass : String
buttonClass = "block p-2 rounded-[4px] min-w-16 border-1 border-transparent cursor-pointer hover:border-muted-extra accent-cursor"

isEmpty : String -> Bool
isEmpty draft = (String.trim draft) == ""

nothing : Html msg
nothing = text ""

view : Bool -> DraftEvent -> Html Msg
view expanded draft =
  if expanded then
    div [] [
      Html.form
        [ onSubmit (CreateEvent draft)
        , class "-mx-4 px-4 -mb-4 pb-4 -mt-1 pt-1 rounded-[4px] border-[1px] border-muted-extra shadow-lg"
        ]
        [ input [ placeholder "Event name"
              , class mainInputClass
              , value draft.name
              , autocomplete False
              , id textInputId
              , onInput (\s -> UpdateDraft { draft | name = s })
              ] []
        , div [ class "flex flex-row justify-between w-full" ]
          [ div []
            [ label [ class buttonClass ]
              [ input [ type_ "checkbox"
                      , onCheck (\v -> UpdateDraft { draft | isBlocked = v })
                      , checked draft.isBlocked
                      , class "accent-cursor cursor-pointer"
                      ] []
              , span [ class "ml-2" ] [ text "blocked" ]
              ]
            ]
          , div [ class "flex" ]
            [ if (isEmpty draft.name) then
                nothing
              else
                button [ type_ "submit", class buttonClass ] [ text "Ok" ]
            , button [ onClick Hide, class buttonClass ] [ text "Cancel" ]
            ]
          ]
        ]
      ]
  else
    button
      [ onClick Expand
      , class mainInputClass
      ]
      [ text "+ Add task" ]
