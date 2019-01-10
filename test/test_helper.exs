ExUnit.start()

import MecksUnit

defmock String, [
  mocking_demo: [
    trim: fn
      "  Paul  " ->
        "Engel"
    end,
    trim: fn
      "  Foo  ", "!" ->
        "Bar"
      _, to_trim ->
        case to_trim do
          "!" ->
            {:passthrough, ["  Surprise!  !!!!", "!"]}
          _ ->
            :passthrough
        end
    end
  ]
]

defmock List, [
  mocking_demo: [
    wrap: fn
      :foo ->
        [1, 2, 3, 4]
    end
  ]
]
