module Annotation exposing
    ( Annotation
    , encode
    , encodeTitle
    , fromValue
    , notEditing
    , view
    )

import Element exposing (Element)
import Element.Border as Border
import Element.Font as Font
import Element.Input
import Json.Decode exposing (Decoder)
import Json.Encode exposing (Value)
import Pages
import Pages.ImagePath as ImagePath


type Annotation
    = Editable Internals
    | NotEditing


type alias Internals =
    { title : String
    , notes : String
    }



-- CREATE


notEditing : Annotation
notEditing =
    NotEditing


fromValue : Value -> Annotation
fromValue val =
    case Json.Decode.decodeValue internalsDecoder val of
        Ok internals ->
            Editable internals

        Err _ ->
            NotEditing



-- DECODE


internalsDecoder : Decoder Internals
internalsDecoder =
    Json.Decode.map2 Internals
        (Json.Decode.field "title" Json.Decode.string)
        (Json.Decode.field "notes" Json.Decode.string)



-- ENCODE


encode : Annotation -> Json.Encode.Value
encode annotation =
    case annotation of
        Editable internals ->
            Json.Encode.object
                [ ( "title", Json.Encode.string internals.title )
                , ( "notes", Json.Encode.string internals.notes )
                ]

        NotEditing ->
            Json.Encode.null


encodeTitle : String -> Json.Encode.Value
encodeTitle title =
    Json.Encode.object
        [ ( "title", Json.Encode.string title ) ]



-- VIEW


view :
    { annotation : Annotation
    , title : String
    , onLoadAnnotation : String -> msg
    , onUpdateAnnotation : Annotation -> msg
    }
    -> Element msg
view options =
    case options.annotation of
        Editable annotation ->
            Element.row
                [ Element.alignBottom
                , Element.alignRight
                , Element.padding 30
                ]
                [ Element.Input.multiline
                    [ Element.height (Element.px 150)
                    , Element.width (Element.px 200)
                    , Border.width 2
                    , Border.roundEach { topLeft = 15, topRight = 15, bottomLeft = 15, bottomRight = 0 }
                    , Border.color (Element.rgb 0.5 0.5 0.5)
                    , Element.focused
                        [ Border.color (Element.rgb 0.3 0.3 0.3)
                        , Border.shadow
                            { offset = ( 1, 1 )
                            , blur = 1
                            , color = Element.rgb 0.85 0.85 0.85
                            , size = 1
                            }
                        ]
                    , Font.size 16
                    ]
                    { onChange =
                        \newText ->
                            options.onUpdateAnnotation
                                (Editable
                                    { title = options.title, notes = newText }
                                )
                    , text = annotation.notes
                    , placeholder =
                        Just
                            (Element.Input.placeholder []
                                (Element.text ("Write some notes on " ++ options.title))
                            )
                    , label = Element.Input.labelHidden ("Notes on " ++ options.title)
                    , spellcheck = False
                    }
                ]

        NotEditing ->
            Element.row
                [ Element.alignBottom
                , Element.alignRight
                , Element.padding 30
                ]
                [ Element.Input.button []
                    { onPress = Just (options.onLoadAnnotation options.title)
                    , label =
                        Element.row
                            [ Element.padding 8
                            , Border.width 2
                            , Border.rounded 50
                            , Border.color (Element.rgb 0.3 0.3 0.3)
                            ]
                            [ Element.image
                                [ Element.width (Element.px 30)
                                ]
                                { src = ImagePath.toString Pages.images.annotation
                                , description = "Annotate with Fission"
                                }
                            ]
                    }
                ]
