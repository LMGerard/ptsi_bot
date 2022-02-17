import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'command.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

final emojis = {
  1: UnicodeEmoji('1️⃣'),
  2: UnicodeEmoji('2️⃣'),
  3: UnicodeEmoji('3️⃣'),
  4: UnicodeEmoji('4️⃣'),
  'right': UnicodeEmoji('✅'),
  'wrong': UnicodeEmoji('❌'),
  'next': UnicodeEmoji('➡️'),
};

class Quizz extends Command with HasButton {
  final List<int> _questionsIds = [];
  Quizz()
      : super('quizz', 'Quizz it up !', [
          // CommandOptionBuilder(
          //   CommandOptionType.string,
          //   'theme',
          //   'theme',
          //   choices: themes.map((e) => ArgChoiceBuilder(e, e)).toList(),
          // )
        ]);

  @override
  FutureOr execute(event) async {
    if (_questionsIds.isEmpty) {
      _questionsIds.addAll(await getRandomQuestionsId());
    }

    sendQuestion(event);
  }

  Future<_Question?> getQuestion(int id) async {
    final res = await http.post(
        Uri.https('www.openquizzdb.org', 'download.php'),
        headers: headers,
        body: 'q=$id',
        encoding: Encoding.getByName('application/x-www-form-urlencoded'));
    final result = parser.parse(res.body).getElementById('clip_txt')?.text;

    if (result == null) return null;
    return _Question.fromHtml(result, id);
  }

  Future<Iterable<int>> getRandomQuestionsId() async {
    final res = await http.post(Uri.https('www.openquizzdb.org', 'random.php'),
        headers: headers);

    return parser
        .parse(res.body)
        .getElementsByClassName('myid')
        .map((e) => int.parse(e.text));
  }

  // Future<Iterable<int>> getQuestionsIdByTheme(String theme) async {
  //   final res = await http.post(Uri.https('www.openquizzdb.org', 'random.php'),
  //       headers: headers,
  //       body: 'categ=$theme&q=0',
  //       encoding: Encoding.getByName('application/x-www-form-urlencoded'));

  //   return parser
  //       .parse(res.body)
  //       .getElementsByClassName('myid')
  //       .map((e) => int.parse(e.text));
  // }

  @override
  Map<String, Function(IButtonInteractionEvent p1)> get buttons => {
        'quizz0': answerSelected,
        'quizz1': answerSelected,
        'quizz2': answerSelected,
        'quizz3': answerSelected,
        'quizz4': answerSelected,
        'next': next,
      };

  void next(event) => sendQuestion(event);

  void sendQuestion(IInteractionEventWithAcknowledge event) async {
    final question = await getQuestion(_questionsIds.removeLast());

    if (question == null) {
      sendEmbed<EMBED_RESPOND>(event, text: 'No question found');
      return;
    }

    final props = question.props..shuffle();
    String text = '\n**${question.question}** : \n```diff\n';

    final msg = ComponentRowBuilder();

    final quizzes = ['quizz1', 'quizz2', 'quizz3'];

    for (int i = 1; i <= 4; i++) {
      final prop = props.removeAt(0);
      text += '\n$i. $prop';

      msg.addComponent(ButtonBuilder(
        '',
        prop == question.prop1 ? 'quizz0' : quizzes.removeAt(0),
        ComponentStyle.secondary,
        emoji: emojis[i],
      ));
    }
    text += '\n```';

    sendEmbed<EMBED_RESPOND>(
      event,
      title: ' - ${question.theme} - ${question.id}',
      componentRowBuilders: [msg],
      text: text,
    );
  }

  answerSelected(IButtonInteractionEvent event) async {
    final msg = event.interaction.message;

    if (msg == null) return event.acknowledge();

    final row = ComponentRowBuilder();
    if (event.interaction.customId == 'quizz0') {
      row.addComponent(ButtonBuilder('', 'quizz0', ComponentStyle.success,
          emoji: emojis['right'], disabled: true));
    } else {
      row.addComponent(ButtonBuilder('', 'quizz0', ComponentStyle.danger,
          emoji: emojis['wrong'], disabled: true));
    }
    row.addComponent(ButtonBuilder('next', 'next', ComponentStyle.primary,
        emoji: emojis['next']));

    final info = msg.embeds.first.title!.split('-');
    final question = await getQuestion(int.parse(info.last));

    sendEmbed<EMBED_RESPOND>(
      event,
      componentRowBuilders: [row],
      text: '**${question?.question}**\n```diff\n+${question?.prop1}\n```',
    );
  }
}

class _Question {
  final String theme;
  final int id;
  final String question;
  final String prop1;
  final String prop2;
  final String prop3;
  final String prop4;

  _Question(this.question, this.theme, this.id, List<String> answers)
      : prop1 = answers[0],
        prop2 = answers[1],
        prop3 = answers[2],
        prop4 = answers[3];

  factory _Question.fromHtml(String html, int id) {
    final data = html.split('\n');

    return _Question(
      data[8],
      data[4],
      id,
      [data[9].replaceFirst('*', '').trim(), data[10], data[11], data[12]],
    );
  }
  List<String> get props => [prop1, prop2, prop3, prop4];
  String get answer => prop1;
  @override
  String toString() {
    return '_Question{theme: $theme, id: $id, question: $question, prop1: $prop1, prop2: $prop2, prop3: $prop3, prop4: $prop4}';
  }
}

const headers = {
  "Host": "www.openquizzdb.org",
  "User-Agent":
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:97.0) Gecko/20100101 Firefox/97.0",
  "Accept":
      "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
  "Accept-Language": "en-US,en;q=0.5",
  "Accept-Encoding": "gzip, deflate, br",
  "Referer": "https://www.openquizzdb.org/download.php",
  "Content-Type": "application/x-www-form-urlencoded",
  "Origin": "https://www.openquizzdb.org",
  "Connection": "keep-alive",
  "Cookie": "oqdb_down_4=1; oqdb_down_124=1; oqdb_down_3=1; oqdb_down_90=1",
  "Upgrade-Insecure-Requests": "1",
  "Sec-Fetch-Dest": "document",
  "Sec-Fetch-Mode": "navigate",
  "Sec-Fetch-Site": "same-origin",
  "Sec-Fetch-User": "?1",
  "TE": "trailers",
  "Pragma": "no-cache",
  "Cache-Control": "no-cache",
  //"Content-Length": "24",
};

const tags = [
  'Acteur',
  'Actrice',
  'Afrique',
  'Album',
  'Allemagne',
  'Amérique',
  'Anatomie',
  'Angleterre',
  'Animateur',
  'Anthropologie',
  'Antiquité',
  'Appareil',
  'Arbre',
  'Argentine',
  'Argot',
  'Article',
  'Artisan',
  'Artiste',
  'Asie',
  'Association',
  'Astronomie',
  'Athlétisme',
  'Auteur',
  'Automobile',
  'automobile',
  'Autriche',
  'Égypte',
  'États-Unis',
  'Île',
  'Bande',
  'dessinée',
  'Basket-ball',
  'Bâtiment',
  'Belgique',
  'Bien-être',
  'BO',
  'Boisson',
  'Botanique',
  'Boxe',
  'Canada',
  'Capitale',
  'César',
  'Champignon',
  'Champion',
  'Chanson',
  'Chanteur',
  'Chanteuse',
  'Chat',
  'Château',
  'Cheval',
  'Chien',
  'Chimie',
  'Chine',
  'Citation',
  'Classique',
  'Climat',
  'Clip',
  'Collection',
  'Comics',
  'Commerce',
  'Concert',
  'Confiserie',
  'Console',
  'Consommation',
  'Conte',
  'Continent',
  'Couleur',
  'Cyclisme',
  'Danse',
  'Décès',
  'Décoration',
  'Dessert',
  'Dessin',
  'animé',
  'Devise',
  'Dicton',
  'Disney',
  'Distance',
  'Divertissement',
  'Drapeau',
  'Eau',
  'Economie',
  'Environnement',
  'Escalade',
  'Espace',
  'Espagne',
  'Espèce',
  'Europe',
  'Eurovision',
  'Expression',
  'Famille',
  'Festival',
  'Fiction',
  'Film',
  'Fleuve',
  'Flore',
  'Folklore',
  'Football',
  'Forêt',
  'France',
  'Fromage',
  'Fruit',
  'Golf',
  'Grèce',
  'Groupe',
  'Guerre',
  'Harry',
  'Potter',
  'Héros',
  'Humour',
  'Inde',
  'Insecte',
  'Instrument',
  'Invention',
  'Irlande',
  'Italie',
  'Japon',
  'Jeu',
  'Jeunesse',
  'JO',
  'Jouet',
  'Journal',
  'Lac',
  'Légende',
  'Linux',
  'Livre',
  'Logiciel',
  'Logique'
      'Logo',
  'Magazine',
  'Mammifère',
  'Manga',
  'Mannequin',
  'Mariage',
  'Maroc',
  'Marque',
  'Matériel',
  'Médecine',
  'Météo',
  'Métier',
  'Mer',
  'Mexique',
  'Mode',
  'Monarchie',
  'Monde',
  'Montagne',
  'Monument',
  'Moyen',
  'Âge',
  'Musée',
  'Mythologie',
  'Naissance',
  'Nationalité',
  'NBA',
  'Noël',
  'Nombre',
  'Objet',
  'Océan',
  'Oiseau',
  'Opéra',
  'Orthographe',
  'Parfum',
  'Paris',
  'Pays',
  'Pays-Bas',
  'Pérou',
  'Peinture',
  'Photographie',
  'Physique',
  'Poésie',
  'Poisson',
  'Pokemon',
  'Politique',
  'Pologne',
  'Pont',
  'Population',
  'Port',
  'Prénom',
  'Présidence',
  'Président',
  'Pseudonyme',
  'Pub',
  'Quotidien',
  'Radio',
  'Réalisateur',
  'Religion',
  'Reptile',
  'Roman',
  'Rome',
  'Royaume-Uni',
  'Royauté',
  'Rugby',
  'Russie',
  'Saint',
  'Santé',
  'Série',
  'Science-fiction',
  'Sculpture',
  'Ski',
  'Slogan',
  'Spectacle',
  'Sportif',
  'Star',
  'Trek',
  'Star',
  'Wars',
  'Stylisme',
  'Suisse',
  'Surnom',
  'surnom',
  'Synonyme',
  'Tableau',
  'Télé-réalité',
  'Technologie',
  'Tennis',
  'Théâtre',
  'Tibet',
  'Tintin',
  'Tradition',
  'Transport',
  'Trophée',
  'Tunisie',
  'Turquie',
  'UNESCO',
  'Vêtement',
  'Ville',
  'Vin',
  'Zodiaque'
];
