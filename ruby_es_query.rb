class FetchPackQuery < ActiveQuery
  def build
    {
      query: {
        filtered: {
          query: { match_all: {} },
          filter: {
            nested: {
              path: "path",
              query:{
                filtered: {
                  query: { match_all: {} },
                  filter: {
                    and: [
                      {term: {'xx.xx': 810 }},
                      {term: {'xx.xx': 2 }}
                    ]
                  }
                }
              }
            }
          }
        }
      }
    }
  end

  def dish_info_filter(param)
    { # start nested
      nested: {
        path: :param,
        score_mode: 'max',
        filter: {
          bool: {
            must: [
              params[:xx].blank? ?
              {
                match_all: {}
              } :
              {
                term: {
                  rrr: eee[:dish_type]
                }
              },
              params[:dishs_info].blank? ?
              {
                match_all: {}
              } :
              {
                term: {
                  platter_type_id: dishs_info[:diet_prefs]
                }
              }
            ]
          }
        },
        query: {
          bool: {
            should: [
              {
                match: {
                  platter_description:{
                    query: dishs_info[:free_text],
                    type: 'phrase',
                    boost: 1
                  }
                }
              },
              {
                match: {
                  platter_short_desciption:{
                    query: dishs_info[:free_text],
                    boost: 2
                  }
                }
              },
              {
                match: {
                  platter_title: {
                    query: dishs_info[:free_text],
                    boost: 3
                  }
                }
              }
            ]
          }
        }
      }
    }
  end


  def dish_info_filter_new(dishs_info)
    { # start nested
      bool: {
        must: {
          term: {
            dish_type: dishs_info[:tt]
          },
          term: {
            platter_type_id: dishs_info[:tt]
          }
        }#,
        # should: {
        #   match: {
        #           platter_description: {
        #             query: dishs_info[:free_text],
        #             type: 'phrase',
        #             boost: 1
        #           }
        #         }
        # }
    }
  }
      # query: {
      #   bool: {
      #     should: [
      #       {
      #         match: {
      #           field:{
      #             query: value,
      #             type: 'phrase',
      #             boost: 1
      #           }
      #         }
      #       },
      #       {
      #         match: {
      #           field:{
      #             query: value,
      #             boost: 2
      #           }
      #         }
      #       },
      #       {
      #         match: {
      #           field: {
      #             query: value,
      #             boost: 3
      #           }
      #         }
      #       }
      #     ]
      #   }
      # }
    # }
  end

end
