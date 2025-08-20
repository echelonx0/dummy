// lib/core/services/email_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sends feedback request email via Firebase Mail extension
  Future<void> sendFeedbackRequestEmail({
    required String userName,
    required String userEmail,
    required String referenceName,
    required String referenceEmail,
    required String relationshipType,
    required String requestCode,
    required String locale,
  }) async {
    try {
      // Create the email document in the mail collection
      // The Firebase Mail extension will automatically process this
      await _firestore.collection('mail').add({
        'to': [referenceEmail],
        'message': {
          'subject': _getEmailSubject(userName, locale),
          'html': _generateEmailHTML(
            userName: userName,
            userEmail: userEmail,
            referenceName: referenceName,
            relationshipType: relationshipType,
            requestCode: requestCode,
            locale: locale,
          ),
          'text': _generateEmailText(
            userName: userName,
            referenceName: referenceName,
            requestCode: requestCode,
            locale: locale,
          ),
        },
        'template': {
          'name': 'feedback-request',
          'data': {
            'userName': userName,
            'referenceName': referenceName,
            'relationshipType': relationshipType,
            'requestCode': requestCode,
            'referenceUrl': _generateReferenceUrl(requestCode),
          },
        },
        'metadata': {
          'type': 'feedback_request',
          'userEmail': userEmail,
          'requestCode': requestCode,
          'sentAt': FieldValue.serverTimestamp(),
        },
      });

      print('✅ Feedback request email queued for $referenceEmail');
    } catch (e) {
      print('❌ Error sending feedback request email: $e');
      rethrow;
    }
  }

  String _getEmailSubject(String userName, String locale) {
    switch (locale) {
      case 'fr':
        return 'Aidez $userName à trouver l\'amour véritable - Votre perspective compte';
      case 'sw':
        return 'Msaada $userName apate upendo wa kweli - Mtazamo wako ni muhimu';
      default:
        return 'Help $userName find meaningful love - Your perspective matters';
    }
  }

  String _generateReferenceUrl(String requestCode) {
    // Replace with your actual domain
    return 'https://yourapp.com/reference/$requestCode';
  }

  String _generateEmailHTML({
    required String userName,
    required String userEmail,
    required String referenceName,
    required String relationshipType,
    required String requestCode,
    required String locale,
  }) {
    final referenceUrl = _generateReferenceUrl(requestCode);

    return '''
    <!DOCTYPE html>
    <html lang="$locale">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${_getEmailSubject(userName, locale)}</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            
            body {
                font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                line-height: 1.6;
                color: #2D2D2D;
                background: linear-gradient(135deg, #F8F7F5 0%, #FFE1E6 100%);
                padding: 20px 0;
            }
            
            .email-container {
                max-width: 600px;
                margin: 0 auto;
                background: white;
                border-radius: 24px;
                overflow: hidden;
                box-shadow: 0 20px 60px rgba(26, 54, 93, 0.15);
            }
            
            .header {
                background: linear-gradient(135deg, #1A365D 0%, #FF6B8A 100%);
                color: white;
                padding: 40px 30px;
                text-align: center;
                position: relative;
            }
            
            .header::before {
                content: '';
                position: absolute;
                top: -50px;
                right: -50px;
                width: 100px;
                height: 100px;
                background: rgba(255, 255, 255, 0.1);
                border-radius: 50%;
            }
            
            .header::after {
                content: '';
                position: absolute;
                bottom: -30px;
                left: -30px;
                width: 60px;
                height: 60px;
                background: rgba(232, 180, 184, 0.3);
                border-radius: 50%;
            }
            
            .header h1 {
                font-size: 28px;
                font-weight: 300;
                margin-bottom: 10px;
                letter-spacing: -0.5px;
            }
            
            .header p {
                font-size: 16px;
                opacity: 0.9;
                font-weight: 400;
            }
            
            .heart-icon {
                width: 60px;
                height: 60px;
                background: rgba(255, 255, 255, 0.2);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 20px;
                border: 2px solid rgba(255, 255, 255, 0.3);
            }
            
            .content {
                padding: 40px 30px;
            }
            
            .greeting {
                font-size: 22px;
                font-weight: 600;
                color: #1A365D;
                margin-bottom: 20px;
            }
            
            .intro-text {
                font-size: 16px;
                margin-bottom: 25px;
                color: #4A5568;
                line-height: 1.7;
            }
            
            .highlight-box {
                background: linear-gradient(135deg, #FFE1E6 0%, #F8F7F5 100%);
                border-left: 4px solid #FF6B8A;
                padding: 25px;
                margin: 30px 0;
                border-radius: 0 16px 16px 0;
            }
            
            .highlight-box h3 {
                color: #1A365D;
                font-size: 18px;
                font-weight: 600;
                margin-bottom: 12px;
            }
            
            .highlight-box p {
                color: #4A5568;
                font-size: 15px;
                line-height: 1.6;
            }
            
            .cta-container {
                text-align: center;
                margin: 40px 0;
            }
            
            .cta-button {
                background: linear-gradient(135deg, #948979 0%, #DFD0B8 100%);
                color: #1A365D;
                padding: 16px 32px;
                text-decoration: none;
                border-radius: 50px;
                font-weight: 600;
                font-size: 16px;
                display: inline-block;
                box-shadow: 0 8px 25px rgba(148, 137, 121, 0.3);
                transition: all 0.3s ease;
                border: 2px solid transparent;
            }
            
            .cta-button:hover {
                transform: translateY(-2px);
                box-shadow: 0 12px 35px rgba(148, 137, 121, 0.4);
                border-color: #948979;
            }
            
            .time-estimate {
                background: #F7FAFC;
                border: 1px solid #E2E8F0;
                border-radius: 12px;
                padding: 20px;
                margin: 25px 0;
                text-align: center;
            }
            
            .time-estimate .clock-icon {
                font-size: 24px;
                margin-bottom: 8px;
                color: #948979;
            }
            
            .footer {
                background: #F8F9FA;
                padding: 30px;
                text-align: center;
                border-top: 1px solid #E2E8F0;
            }
            
            .footer p {
                font-size: 14px;
                color: #6B7280;
                margin-bottom: 10px;
            }
            
            .footer .disclaimer {
                font-size: 12px;
                color: #9CA3AF;
                font-style: italic;
            }
            
            .user-info {
                background: rgba(148, 137, 121, 0.1);
                border-radius: 16px;
                padding: 20px;
                margin: 25px 0;
            }
            
            .user-info h4 {
                color: #1A365D;
                font-size: 16px;
                font-weight: 600;
                margin-bottom: 8px;
            }
            
            .user-info p {
                color: #4A5568;
                font-size: 14px;
            }
            
            @media (max-width: 600px) {
                .email-container {
                    margin: 0 10px;
                    border-radius: 16px;
                }
                
                .header, .content, .footer {
                    padding: 25px 20px;
                }
                
                .header h1 {
                    font-size: 24px;
                }
                
                .cta-button {
                    padding: 14px 28px;
                    font-size: 15px;
                }
            }
        </style>
    </head>
    <body>
        <div class="email-container">
            <div class="header">
                <div class="heart-icon">
                    ❤️
                </div>
                <h1>${_getEmailTitle(locale)}</h1>
                <p>${_getEmailSubtitle(locale)}</p>
            </div>
            
            <div class="content">
                <div class="greeting">
                    ${_getGreeting(referenceName, locale)}
                </div>
                
                <p class="intro-text">
                    ${_getIntroText(userName, locale)}
                </p>
                
                <div class="user-info">
                    <h4>${_getUserInfoTitle(locale)}</h4>
                    <p><strong>${_getNameLabel(locale)}:</strong> $userName</p>
                    <p><strong>${_getRelationshipLabel(locale)}:</strong> ${_getLocalizedRelationshipType(relationshipType, locale)}</p>
                </div>
                
                <div class="highlight-box">
                    <h3>${_getWhatWeNeedTitle(locale)}</h3>
                    <p>${_getWhatWeNeedText(userName, locale)}</p>
                </div>
                
                <div class="time-estimate">
                    <div class="clock-icon">⏱️</div>
                    <p><strong>${_getTimeEstimate(locale)}</strong></p>
                </div>
                
                <div class="cta-container">
                    <a href="$referenceUrl" class="cta-button">
                        ${_getCtaText(locale)} →
                    </a>
                </div>
            </div>
            
            <div class="footer">
                <p>${_getFooterText(userName, locale)}</p>
                <p class="disclaimer">${_getDisclaimer(locale)}</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  String _generateEmailText({
    required String userName,
    required String referenceName,
    required String requestCode,
    required String locale,
  }) {
    final referenceUrl = _generateReferenceUrl(requestCode);

    switch (locale) {
      case 'fr':
        return '''
Salut $referenceName!

$userName vous a demandé de fournir une référence de caractère dans le cadre de sa candidature à une plateforme de mise en relation exclusive.

Votre perspective honnête sur la personnalité et les qualités relationnelles de $userName aidera à créer une image plus complète pour les correspondances potentielles.

Cela prendra environ 5 minutes de votre temps.

Fournir une référence: $referenceUrl

Cette référence est confidentielle et ne sera utilisée que pour améliorer le profil de mise en relation de $userName.

Si vous avez reçu cet email par erreur ou préférez ne pas participer, vous pouvez simplement l'ignorer.
        ''';
      case 'sw':
        return '''
Hujambo $referenceName!

$userName amekuomba utoe rejeo la tabia kama sehemu ya maombi yake kwa jukwaa la kipekee la kuunganisha.

Mtazamo wako wa uaminifu kuhusu uongozi wa $userName na ubora wa mahusiano utasaidia kuunda picha kamili zaidi kwa mechi zinazowezekana.

Hii itachukua dakika 5 za muda wako.

Toa Rejeo: $referenceUrl

Rejeo hili ni la siri na litatumika tu kuboresha wasifu wa kuunganisha wa $userName.

Ikiwa umepokea barua pepe hii kwa makosa au unapendelea kutojiungua, unaweza kuipuuza tu.
        ''';
      default:
        return '''
Hi $referenceName!

$userName has asked you to provide a character reference as part of their application to an exclusive matchmaking platform.

Your honest perspective about $userName's personality and relationship qualities will help create a more complete picture for potential matches.

This will take about 5 minutes of your time.

Provide Reference: $referenceUrl

This reference is confidential and will only be used to enhance $userName's matchmaking profile.

If you received this email in error or prefer not to participate, you can simply ignore it.
        ''';
    }
  }

  // Localization helper methods
  String _getEmailTitle(String locale) {
    switch (locale) {
      case 'fr':
        return 'Demande de Référence';
      case 'sw':
        return 'Ombi la Rejeo';
      default:
        return 'Character Reference Request';
    }
  }

  String _getEmailSubtitle(String locale) {
    switch (locale) {
      case 'fr':
        return 'Votre perspective compte pour une mise en relation significative';
      case 'sw':
        return 'Mtazamo wako ni muhimu kwa kuunganisha kwa maana';
      default:
        return 'Your perspective matters for meaningful connection';
    }
  }

  String _getGreeting(String name, String locale) {
    switch (locale) {
      case 'fr':
        return 'Salut $name!';
      case 'sw':
        return 'Hujambo $name!';
      default:
        return 'Hi $name!';
    }
  }

  String _getIntroText(String userName, String locale) {
    switch (locale) {
      case 'fr':
        return '$userName vous a demandé de fournir une référence de caractère dans le cadre de sa candidature à notre plateforme de mise en relation exclusive.';
      case 'sw':
        return '$userName amekuomba utoe rejeo la tabia kama sehemu ya maombi yake kwa jukwaa letu la kipekee la kuunganisha.';
      default:
        return '$userName has asked you to provide a character reference as part of their application to our exclusive matchmaking platform.';
    }
  }

  String _getUserInfoTitle(String locale) {
    switch (locale) {
      case 'fr':
        return 'À propos de cette demande';
      case 'sw':
        return 'Kuhusu ombi hili';
      default:
        return 'About this request';
    }
  }

  String _getNameLabel(String locale) {
    switch (locale) {
      case 'fr':
        return 'Nom';
      case 'sw':
        return 'Jina';
      default:
        return 'Name';
    }
  }

  String _getRelationshipLabel(String locale) {
    switch (locale) {
      case 'fr':
        return 'Votre relation';
      case 'sw':
        return 'Uhusiano wako';
      default:
        return 'Your relationship';
    }
  }

  String _getWhatWeNeedTitle(String locale) {
    switch (locale) {
      case 'fr':
        return 'Ce dont nous avons besoin';
      case 'sw':
        return 'Kile tunachohitaji';
      default:
        return 'What we need';
    }
  }

  String _getWhatWeNeedText(String userName, String locale) {
    switch (locale) {
      case 'fr':
        return 'Votre perspective honnête sur la personnalité et les qualités relationnelles de $userName aidera à créer une image plus complète pour les correspondances potentielles.';
      case 'sw':
        return 'Mtazamo wako wa uaminifu kuhusu uongozi wa $userName na ubora wa mahusiano utasaidia kuunda picha kamili zaidi kwa mechi zinazowezekana.';
      default:
        return 'Your honest perspective about $userName\'s personality and relationship qualities will help create a more complete picture for potential matches.';
    }
  }

  String _getTimeEstimate(String locale) {
    switch (locale) {
      case 'fr':
        return 'Cela prendra environ 5 minutes';
      case 'sw':
        return 'Hii itachukua dakika 5';
      default:
        return 'This will take about 5 minutes';
    }
  }

  String _getCtaText(String locale) {
    switch (locale) {
      case 'fr':
        return 'Fournir une Référence';
      case 'sw':
        return 'Toa Rejeo';
      default:
        return 'Provide Reference';
    }
  }

  String _getFooterText(String userName, String locale) {
    switch (locale) {
      case 'fr':
        return 'Cette référence est confidentielle et ne sera utilisée que pour améliorer le profil de mise en relation de $userName.';
      case 'sw':
        return 'Rejeo hili ni la siri na litatumika tu kuboresha wasifu wa kuunganisha wa $userName.';
      default:
        return 'This reference is confidential and will only be used to enhance $userName\'s matchmaking profile.';
    }
  }

  String _getDisclaimer(String locale) {
    switch (locale) {
      case 'fr':
        return 'Si vous avez reçu cet email par erreur ou préférez ne pas participer, vous pouvez simplement l\'ignorer.';
      case 'sw':
        return 'Ikiwa umepokea barua pepe hii kwa makosa au unapendelea kutojiungua, unaweza kuipuuza tu.';
      default:
        return 'If you received this email in error or prefer not to participate, you can simply ignore it.';
    }
  }

  String _getLocalizedRelationshipType(String type, String locale) {
    switch (locale) {
      case 'fr':
        switch (type) {
          case 'Friend':
            return 'Ami(e)';
          case 'Family Member':
            return 'Membre de la Famille';
          case 'Former Partner':
            return 'Ancien(ne) Partenaire';
          case 'Colleague':
            return 'Collègue';
          case 'Roommate':
            return 'Colocataire';
          default:
            return type;
        }
      case 'sw':
        switch (type) {
          case 'Friend':
            return 'Rafiki';
          case 'Family Member':
            return 'Mwanafamilia';
          case 'Former Partner':
            return 'Mshirika wa Zamani';
          case 'Colleague':
            return 'Mwenzangu Kazini';
          case 'Roommate':
            return 'Mwenzi wa Chumba';
          default:
            return type;
        }
      default:
        return type;
    }
  }
}
