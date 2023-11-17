CTranslationUnit
  ( Range
      { start = AlexPn 40 7 1,
        stop = AlexPn 56 7 17
      }
  )
  [ CDeclExt
      ( Range
          { start = AlexPn 40 7 1,
            stop = AlexPn 56 7 17
          }
      )
      ( CDeclaration
          ( Range
              { start = AlexPn 40 7 1,
                stop = AlexPn 56 7 17
              }
          )
          ( CTypeSpec
              ( Range
                  { start = AlexPn 40 7 1,
                    stop = AlexPn 43 7 4
                  }
              )
              ( CIntType
                  ( Range
                      { start = AlexPn 40 7 1,
                        stop = AlexPn 43 7 4
                      }
                  )
              )
              Nothing
          )
          [ CInitDeclarator
              ( Range
                  { start = AlexPn 44 7 5,
                    stop = AlexPn 55 7 16
                  }
              )
              ( Declarator
                  ( Range
                      { start = AlexPn 44 7 5,
                        stop = AlexPn 55 7 16
                      }
                  )
                  ( NestedDecl
                      ( Range
                          { start = AlexPn 44 7 5,
                            stop = AlexPn 55 7 16
                          }
                      )
                      ( PtrDeclarator
                          ( Range
                              { start = AlexPn 45 7 6,
                                stop = AlexPn 50 7 11
                              }
                          )
                          ( CPointer
                              ( Range
                                  { start = AlexPn 45 7 6,
                                    stop = AlexPn 46 7 7
                                  }
                              )
                              []
                              Nothing
                          )
                          ( CIdentDecl
                              ( Range
                                  { start = AlexPn 46 7 7,
                                    stop = AlexPn 50 7 11
                                  }
                              )
                              ( CId
                                  ( Range
                                      { start = AlexPn 46 7 7,
                                        stop = AlexPn 50 7 11
                                      }
                                  )
                                  "ptar"
                              )
                              Nothing
                          )
                      )
                      ( Just
                          ( ArrayModifier
                              ( Range
                                  { start = AlexPn 51 7 12,
                                    stop = AlexPn 55 7 16
                                  }
                              )
                              ( CConstExpr
                                  ( IntConst
                                      ( Range
                                          { start = AlexPn 52 7 13,
                                            stop = AlexPn 54 7 15
                                          }
                                      )
                                      "10"
                                  )
                              )
                              Nothing
                          )
                      )
                  )
              )
              Nothing
          ]
      )
  ]