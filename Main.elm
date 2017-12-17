module Main exposing (..)

import Html
import Http
import Color
import Json.Decode as Decode
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Element.Input as Input
import Style exposing (..)
import Style.Background as Background
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font
import Style.Shadow as Shadow
import Style.Transition as Transition


type Styles
    = None
    | Page
    | Button
    | Field
    | Error


stylesheet : StyleSheet Styles variation
stylesheet =
    Style.styleSheet
        [ style None []
        , style Page
            [ Color.text Color.darkCharcoal
            , Color.background Color.white
            , Font.typeface
                [ Font.font "helvetica"
                , Font.font "arial"
                , Font.font "sans-serif"
                ]
            , Font.size 16
            , Font.lineHeight 1.3
            ]
        , style Button
            [ Border.rounded 5
            , Border.all 1
            , Border.solid
            , Font.bold
            , Color.text Color.white
            , Color.border Color.blue
            , Color.background Color.lightBlue
            ]
        , style Field
            [ Font.bold
            , Border.rounded 5
            , Border.all 1
            , Border.solid
            , Color.border Color.lightGrey
            ]
        , style Error
            [ Color.text Color.red ]
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- model


type alias Model =
    { topic : String
    , gifUrl : String
    }


init : ( Model, Cmd Msg )
init =
    ( Model "cats" "loading.gif", getRandomGif "cats" )



-- update


type Msg
    = ChangeTopic String
    | MorePlease
    | NewGif (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeTopic newTopic ->
            ( { model | topic = newTopic }, getRandomGif newTopic )

        MorePlease ->
            ( { model | gifUrl = "loading.gif" }, getRandomGif model.topic )

        NewGif (Ok newUrl) ->
            ( { model | gifUrl = newUrl }, Cmd.none )

        NewGif (Err _) ->
            ( model, Cmd.none )



-- view


view : Model -> Html.Html Msg
view model =
    Element.layout stylesheet <|
        column Page
            [ center, padding 30, spacing 20, width fill ]
            [ row None
                [ center ]
                [ Input.text Field
                    [ width (px 200), height (px 40), padding 10 ]
                    { onChange = ChangeTopic
                    , value = model.topic
                    , label =
                        Input.placeholder
                            { label = Input.labelLeft (el None [ verticalCenter ] (text "Search:"))
                            , text = "cats"
                            }
                    , options =
                        [ -- Input.errorBelow (el Error [] (text "This is an Error!")),
                          Input.focusOnLoad
                        ]
                    }
                ]
            , image None
                [ height (px 500)
                ]
                { src = model.gifUrl, caption = "gif image of " ++ model.topic }
            , button Button [ width (px 200), height (px 40), onClick MorePlease ] (text "More Please")
            ]


getRandomGif : String -> Cmd Msg
getRandomGif topic =
    let
        url =
            "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic

        request =
            Http.get url decodeImgUrl
    in
        Http.send NewGif request


decodeImgUrl : Decode.Decoder String
decodeImgUrl =
    Decode.at [ "data", "image_url" ] Decode.string
