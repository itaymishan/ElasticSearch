class PackageOfferingQuery < ActiveQuery
  def build
    {
      size: 100,
      query: {
        bool: {
          should: [
            params[:free_txt].blank? ? {
              match_all: { }
            } :
            {
              match: {
                description:{
                  query: params[:free_text],
                  boost: 1
                }
              }
            },
            params[:free_txt].blank? ? {
              match_all: { }
            } :
            {
              match: {
                title: {
                  query: params[:free_text],
                  boost: 2
                }
              }
            }
          ],
          must: [
            # Must have restaurant locations.
            {
              nested: {
                path: :restaurant_locations,
                filter: {
                  match_all: {
                    
                  }
                }
              }
            },
            {
              nested: {
                path: :platter_sizes,
                query: {
                  bool: {
                    must: [
                      params[:price_per_person].blank? ?
                      {
                        match_all: {}
                      } :
                      {
                        range: {
                          price_per_person: {
                            lte: params[:price_per_person],
                            gte: params[:price_per_person] - 3
                          }
                        }
                      },
                      params[:min_people].blank? ?
                      {
                        match_all: {}
                      } :
                      {
                        range: {
                          min_people: {
                            lte: params[:min_people]
                          }
                        }
                      }
                    ]
                  }
                }
              }
            },
            # Shuffling by seed value.
            params[:seed].blank? ? {
              match_all: { }
            } :
            {
              function_score: {
                random_score: {
                  seed: params[:seed]
                }
              }
            },
            # Constraint for platter.
            params[:platter].blank? ? {
              match_all: { }
            } :
            {
              term: {
                platter_id: params[:platter_id]
              }
            },
            # Constraint for platter dish.
            params[:platter_dish_id].blank? ? {
              match_all: { }
            } :
            {
              term: {
                platter_dish_id: params[:platter_dish_id]
              }
            },
            # Constraint for platter types.
            params[:platter_type_ids].blank? ? {
              match_all: { }
            } :
            {
              bool: {
                must: Array(params[:platter_type_ids]).map { |platter_type_id|
                  { term: { platter_type_ids: platter_type_id } }
                }
              }
            },
            # Constraint for restaurant.
            params[:restaurant_id].blank? ? {
              match_all: { }
            } :
            {
              term: {
                restaurant_id: params[:restaurant_id]
              }
            },
            # Constraint for restaurant types.
            params[:restaurant_type_ids].blank? ? {
              match_all: { }
            } :
            {
              bool: {
                should: Array(params[:restaurant_type_ids]).map { |restaurant_type_id|
                  { term: { restaurant_type_ids: restaurant_type_id } }
                }
              }
            },
            # Constraint for restaurant location.
            params[:restaurant_location_id].blank? ? {
              match_all: { }
            } :
            {
              nested: {
                path: :restaurant_locations,
                filter: {
                  term: {
                    restaurant_location_id: params[:restaurant_location_id]
                  }
                }
              }
            },
            # Constraint for active state.
            params[:active].nil? ? {
              match_all: { }
            } :
            {
              term: {
                active: params[:active]
              }
            },
            # Constraint for location.
            params[:coords].blank? ? {
              match_all: { }
            } :
            {
              nested: {
                path: :restaurant_locations,
                filter: {
                  geo_shape: params[:radius].blank? ? {
                    # Delivery locations within area.
                    delivery_area: {
                      shape: {
                        type: 'point',
                        coordinates: [
                          params[:coords][:lon],
                          params[:coords][:lat]
                        ]
                      }
                    }
                  } :
                  {
                    # Restaurants within area.
                    location: {
                      shape: {
                        type: 'circle',
                        coordinates: [
                          params[:coords][:lon],
                          params[:coords][:lat]
                        ],
                        radius: "#{params[:radius]}km"
                      }
                    }
                  }
                }
              }
            },
            # Constraint on order notice.
            params[:order_notice].blank? ? {
              match_all: { }
            } :
            order_notice_filter,
            # Constraint for business hours.
            params[:datetime].blank? ? {
              match_all: { }
            } :
            {
              nested: {
                path: :restaurant_locations,
                filter: {
                  bool: {
                    must: [
                      # Constrain for day.
                      params[:datetime][:day].blank? ? {
                        match_all: { }
                      } :
                      {
                        term: {
                          days: params[:datetime][:day]
                        }
                      },
                      # Constrain for start and end time.
                      params[:datetime][:time].blank? ? {
                        match_all: { }
                      } :
                      {
                        bool: {
                          must: [
                            {
                              range: {
                                start_time: {
                                  lte: params[:datetime][:time]
                                }
                              }
                            },
                            {
                              range: {
                                end_time: {
                                  gte: params[:datetime][:time]
                                }
                              }
                            }
                          ]
                        }
                      }
                    ]
                  }
                }
              }
            }
          ]
        }
      },
      aggs: {
        deliverable: {
          nested: {
            path: :restaurant_locations
          },
          aggs: {
            restaurant_locations: {
              terms: {
                size: 100, # TODO : See how this interacts with pagination.
                field: :restaurant_location_id
              }
            }
          }
        }
      }
    }
  end

private

end
