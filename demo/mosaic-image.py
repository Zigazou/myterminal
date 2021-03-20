#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""ImageMyTerminal est une classe permettant de convertir une image lisible par
PIL en semi-graphiques pour le MyTerminal.

"""

from operator import itemgetter
from math import sqrt
import sys
from PIL import Image

def myt_print(string):
    if type(string) is bytes:
        sys.stdout.buffer.write(string)
    elif type(string) is int:
        sys.stdout.buffer.write(bytes([string]))
    elif type(string) is list:
        for elt in string:
            myt_print(elt)
    elif type(string) is str:
        sys.stdout.buffer.write(string.encode(MYT))

MYT = 'ISO-8859-15'

MYT_PALETTE = [
    (0, 0, 0),
    (128, 0, 0),
    (0, 128, 0),
    (128, 128, 0),
    (0, 0, 128),
    (128, 0, 128),
    (0, 128, 128),
    (192, 192, 192),
    (128, 128, 128),
    (255, 0, 0),
    (0, 255, 0),
    (255, 255, 0),
    (0, 0, 255),
    (255, 0, 255),
    (0, 255, 255),
    (255, 255, 255)
]

def cls():
    myt_print([ 0x01, 0x21, 0x13 ])

def myt_label(colonne, ligne, sublabel):
    myt_print([ 0x04, 0x30 + ligne, 0x30 + colonne, 0x13 ])
    myt_print([ 0x05, 0x33, 0x02, 0x40 + 11, 0x02, 0x50 + 4 ])
    myt_print("MyTerminal    ")
    myt_print([ 0x04, 0x30 + ligne + 2, 0x30 + colonne ])
    myt_print([ 0x05, 0x30 ])
    myt_print(sublabel)

def color_distance(color1, color2):
    return (
        (color1[0] - color2[0]) ** 2 +
        (color1[1] - color2[1]) ** 2 +
        (color1[2] - color2[2]) ** 2
    )

def find_closest_in_palette(color):
    best_distance = 3 * 256 ** 2
    best_index = -1

    for index in range(16):
        distance = color_distance(color, MYT_PALETTE[index])
        if distance < best_distance:
            best_distance = distance
            best_index = index

    return best_index

def _deux_couleurs(couleurs):
    """Réduit une liste de couleurs à un couple de deux couleurs.

    Les deux couleurs retenues sont les couleurs les plus souvent
    présentes.

    :param couleurs:
        Les couleurs à réduire. Chaque couleur doit être un entier compris
        entre 0 et 7 inclus.
    :type couleurs:
        Une liste d’entiers

    :returns:
        Un tuple de deux entiers représentant les couleurs sélectionnées.
    """
    assert isinstance(couleurs, list)

    # Crée une liste contenant le nombre de fois où un niveau est
    # enregistré
    niveaux = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    # Passe en revue tous les niveaux pour les comptabiliser
    for couleur in couleurs:
        niveaux[couleur] += 1

    # Prépare la liste des niveaux afin de pouvoir la trier du plus
    # utilisé au moins utilisé. Pour cela, on crée une liste de tuples
    # (niveau, nombre d’apparitions)
    niveaux = [(index, valeur) for index, valeur in enumerate(niveaux)]

    # Trie les niveaux par nombre d’apparition
    niveaux = sorted(niveaux, key = itemgetter(1), reverse = True)

    # Retourne les deux niveaux les plus rencontrés
    return (niveaux[0][0], niveaux[1][0])

def _arp_ou_avp(couleur, arp, avp):
    """Convertit une couleur en couleur d’arrière-plan ou d’avant-plan.

    La conversion se fait en calculant la proximité de la couleur avec la
    couleur d’arrière-plan (arp) et avec la couleur d’avant-plan (avp).

    :param couleur:
        La couleur à convertir (valeur de 0 à 7 inclus).
    :type couleur:
        un entier

    :param arp:
        La couleur d’arrière-plan (valeur de 0 à 7 inclus)
    :type arp:
        un entier

    :param avp:
        La couleur d’avant-plan (valeur de 0 à 7 inclus)
    :type avp:
        un entier

    :returns:
        0 si la couleur est plus proche de la couleur d’arrière-plan, 1 si
        la couleur est plus proche de la couleur d’avant-plan.
    """
    assert isinstance(couleur, int)
    assert isinstance(arp, int)
    assert isinstance(avp, int)

    if(abs(arp - couleur) < abs(avp - couleur)):
        return 0

    return 1

def _myterminal_arp(niveau):
    """Convertit un niveau en une séquence de codes MyTerminal définissant la
    couleur d’arrière-plan.

    :param niveau:
        Le niveau à convertir (valeur de 0 à 15 inclus).
    :type niveau:
        un entier

    :returns:
        Un objet de type Sequence contenant la séquence à envoyer au
        MyTerminal pour avec une couleur d’arrière-plan correspondant au
        niveau.
    """
    assert isinstance(niveau, int)

    return [ 0x02, 0x50 + niveau ]

def _myterminal_avp(niveau):
    """Convertit un niveau en une séquence de codes MyTerminal définissant la
    couleur d’avant-plan.

    :param niveau:
        Le niveau à convertir (valeur de 0 à 15 inclus).
    :type niveau:
        un entier

    :returns:
        Un objet de type Sequence contenant la séquence à envoyer au
        MyTerminal pour avec une couleur d’avant-plan correspondant au niveau.
    """
    assert isinstance(niveau, int)

    return [ 0x02, 0x40 + niveau ]

class ImageMyTerminal:
    """Une classe de gestion d’images MyTerminal avec conversion depuis une
    image lisible par PIL.

    Cette classe gère une image au sens MyTerminal du terme, c’est à dire par
    l’utilisation du mode semi-graphique dans lequel un caractère contient
    une combinaison de 2×3 pixels. Cela donne une résolution maximale de 160×153
    pixels.
    
    Hormis la faible résolution ainsi obtenue, le mode semi-graphique présente
    plusieurs inconvénients par rapport à un véritable mode graphique :

    - il ne peut y avoir que 2 couleurs par bloc de 2×3 pixels,
    - les pixels ne sont pas carrés
    """

    def __init__(self):
        """Constructeur
        """

        # L’image est stockées sous forme de listes afin de pouvoir l’afficher à
        # n’importe quelle position sur l’écran
        self.sequences = []

        self.largeur = 0
        self.hauteur = 0

    def envoyer(self, colonne = 0, ligne = 0):
        """Envoie l’image sur le MyTerminal à une position donnée

        Sur le MyTerminal, la première colonne a la valeur 1. La première ligne
        a également la valeur 1 bien que la ligne 0 existe. Cette dernière
        correspond à la ligne d’état et possède un fonctionnement différent
        des autres lignes.

        :param colonne:
            colonne à laquelle positionner le coin haut gauche de l’image
        :type colonne:
            un entier

        :param ligne:
            ligne à laquelle positionner le coin haut gauche de l’image
        :type ligne:
            un entier
        """
        assert isinstance(colonne, int)
        assert isinstance(ligne, int)

        sortie = []
        for sequence in self.sequences:
            #sortie += [ 0x04, 0x30 + ligne, 0x30 + colonne ]
            sortie += sequence
            ligne += 1

        return sortie

    def importer(self, image):
        """Importe une image de PIL et crée les séquences de code MyTerminal
        correspondantes. L’image fournie doit avoir été réduite à des
        dimensions inférieures ou égales à 160×153 pixels. La largeur doit être
        un multiple de 2 et la hauteur un multiple de 3.

        :param image:
            L’image à importer.
        :type niveau:
            une Image
        """
        assert image.size[0] <= 320
        assert image.size[1] <= 255

        # En mode semi-graphique, un caractère a 2 pixels de largeur
        # et 3 pixels de hauteur
        self.largeur = int(image.size[0] / 4)
        self.hauteur = int(image.size[1] / 5)

        # Initialise la liste des séquences
        self.sequences = []

        old_avp = -1
        old_arp = -1
        for hauteur in range(0, self.hauteur):
            # Initialise une nouvelle séquence
            sequence = []

            # Passe en mode semi-graphique
            sequence.append(0x18)

            for largeur in range(0, self.largeur):
                # Récupère 20 pixels
                pixels = [
                    image.getpixel((largeur * 4 + x, hauteur * 5 + y))
                    for x, y in [
                        (0, 0), (1, 0), (2, 0), (3, 0),
                        (0, 1), (1, 1), (2, 1), (3, 1),
                        (0, 2), (1, 2), (2, 2), (3, 2),
                        (0, 3), (1, 3), (2, 3), (3, 3),
                        (0, 4), (1, 4), (2, 4), (3, 4),
                    ]
                ]

                # Convertit chaque couleur de pixel en seize niveaux de gris
                pixels = [find_closest_in_palette(pixel) for pixel in pixels]

                # Recherche les deux couleurs les plus fréquentes
                # un caractère ne peut avoir que deux couleurs !
                arp, avp = _deux_couleurs(pixels)
                if avp == 0:
                    swap = arp
                    arp = avp
                    avp = swap

                # Réduit à deux le nombre de couleurs dans un bloc de 20 pixels
                # Cela peut faire apparaître des artefacts mais est inévitable
                pixels = [_arp_ou_avp(pixel, arp, avp) for pixel in pixels]

                # Convertit les 20 pixels en 3 octets.
                byte0 = int(''.join([
                    "1",
                    str(pixels[0]),
                    str(pixels[1]),
                    str(pixels[2]),
                    str(pixels[3]),
                    str(pixels[4]),
                    str(pixels[5]),
                    str(pixels[6])
                ]), 2)

                byte1 = int(''.join([
                    "1",
                    str(pixels[7]),
                    str(pixels[8]),
                    str(pixels[9]),
                    str(pixels[10]),
                    str(pixels[11]),
                    str(pixels[12]),
                    str(pixels[13])
                ]), 2)

                byte2 = int(''.join([
                    "1",
                    "0",
                    str(pixels[14]),
                    str(pixels[15]),
                    str(pixels[16]),
                    str(pixels[17]),
                    str(pixels[18]),
                    str(pixels[19])
                ]), 2)

                # Génère les codes MyTerminal
                if old_arp != arp:
                    sequence += _myterminal_arp(arp)
                    old_arp = arp

                if old_avp != avp:
                    sequence += _myterminal_avp(avp)
                    old_avp = avp

                sequence += [ byte0, byte1, byte2 ]

            # Une ligne vient d’être terminée, on la stocke dans la liste des
            # séquences
            self.sequences.append(sequence)

convert = ImageMyTerminal()
bear = Image.open("cat-marta-simon-pixabay.png")
convert.importer(bear)
cls()
bear_out = convert.envoyer()[:-3]
myt_print(bear_out)
myt_label(80 - 29, 48, "Cat by Marta Simon / Pixabay")
