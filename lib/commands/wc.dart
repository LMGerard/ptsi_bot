import 'dart:convert';
import 'package:vector_math/vector_math.dart';
import 'package:ptsi_bot_2/commands.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:http/http.dart' as http;

class WC extends Command {
  final url =
      'https://opendata.paris.fr/api/records/1.0/search/?dataset=sanisettesparis&q=&facet=type&facet=statut&facet=arrondissement&facet=horaire&facet=acces_pmr&facet=relais_bebe&refine.arrondissement=%';
  WC() : super('wc', 'Rencontre les toilettes de ta région;');

  @override
  Function get execute => (IChatContext context, int arrondissement) async {
        if (arrondissement < 1 || arrondissement > 20) {
          return respond(context, text: 'Invalid arrondissement');
        }
        final arr = '75${'$arrondissement'.padLeft(3, '0')}';
        final response = await http.get(Uri.parse(url.replaceFirst('%', arr)));
        final dataset = (jsonDecode(response.body)['records'] as List)
            .cast<Map<String, dynamic>>();

        final toilettes = dataset.map(__Toilette.new);

        respond(
          context,
          text:
              "Voici les toilettes publiques de l'arrondissement $arrondissement:\n\n${toilettes.map((e) => e.toString()).join('\n\n')}",
        );
      };
}

class __Toilette {
  final Vector2 geometry;
  final String adresse;
  final String arrondissement;
  final String horaire;
  final String relaisBebe;
  final String accesPmr;

  __Toilette(Map<String, dynamic> data)
      : adresse = data['fields']['adresse'] ?? 'Inconnue',
        accesPmr = data['fields']['acces_pmr'] ?? 'Inconnu',
        arrondissement = data['fields']['arrondissement'] ?? 'Inconnu',
        horaire = data['fields']['horaire'] ?? 'Inconnue',
        relaisBebe = data['fields']['relais_bebe'] ?? 'Inconnu',
        geometry = Vector2(data['geometry']['coordinates'][0] ?? 0,
            data['geometry']['coordinates'][1] ?? 0);

  @override
  String toString() {
    return '$adresse ($arrondissement):\n - Horaire: $horaire\n - Accès PMR: $accesPmr\n - Relais bébé: $relaisBebe';
  }
}
