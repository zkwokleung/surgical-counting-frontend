// A dictionary of all the instruments and their data
const Map<String, Map<String, dynamic>> defaultInstrumentsData = {
  'iris_scissor': {
    'name': 'Iris Scissor',
    'description':
        'A small scissor with sharp blades used for cutting delicate tissue.',
    'image': 'images/instruments/iris_scissor.jpg',
    'order': 0,
    'qty': 1,
  },
  "needle_holder": {
    "name": "Needle Holder",
    "description":
        "A surgical instrument used to hold a suturing needle for closing wounds during suturing and surgical procedures.",
    "image": "images/instruments/needle_holder.jpg",
    "order": 1,
    'qty': 1,
  },
  "bip_fx": {
    "name": "Bipolar Forceps",
    "description":
        "A surgical instrument used to coagulate small blood vessels.",
    "image": "images/instruments/bip_fx.jpg",
    "order": 2,
    'qty': 1,
  },
  "speculum": {
    "name": "Speculum",
    "description":
        "A medical tool for investigating body orifices, with a form dependent on the orifice for which it is designed.",
    "image": "images/instruments/speculum.jpg",
    "order": 3,
    'qty': 1,
  },
  "con_scissor": {
    "name": "Conventional Scissor",
    "description":
        "A scissor with two blades used for cutting tissue and other materials.",
    "image": "images/instruments/con_scissor.jpg",
    "order": 4,
    'qty': 1,
  },
  "spatula": {
    "name": "Spatula",
    "description":
        "A small implement with a broad, flat, flexible blade used to mix, spread, and lift material.",
    "image": "images/instruments/spatula.jpg",
    "order": 5,
    'qty': 1,
  },
  "cap_fx": {
    "name": "Capsulorhexis Forceps",
    "description":
        "A forceps used to create a circular tear in the anterior capsule of the lens during cataract surgery.",
    "image": "images/instruments/cap_fx.jpg",
    "order": 6,
    'qty': 1,
  },
  "suction_cannula": {
    "name": "Suction Cannula",
    "description": "A hollow tube used to remove fluid from a body cavity.",
    "image": "images/instruments/suction_cannula.jpg",
    "order": 7,
    'qty': 1,
  },
  "curved_cannula": {
    "name": "Curved Cannula",
    "description": "A hollow tube used to remove fluid from a body cavity.",
    "image": "images/instruments/curved_cannula.jpg",
    "order": 8,
    'qty': 1,
  },
};
