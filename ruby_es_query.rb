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
                      {term: {'rr.ee': 810 }},
                      {term: {'dishes_info.dish_type': 2 }}
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

  def dish_info_filter(dishs_info)
    { # start nested
      nested: {
        path: :dishes_info,
        score_mode: 'max',
        filter: {
          bool: {
            must: [
              params[:dish_type].blank? ?
              {
                match_all: {}
              } :
              {
                term: {
                  dish_type: dishs_info[:dish_type]
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
            dish_type: dishs_info[:dish_type]
          },
          term: {
            platter_type_id: dishs_info[:diet_prefs]
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
