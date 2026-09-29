import 'dart:async';

import '../models/chat_message.dart';
import '../models/educational_source.dart';

class _RetrievedFact {
  const _RetrievedFact({
    required this.fact,
    required this.provider,
    required this.url,
  });

  final String fact;
  final String provider;
  final String url;
}

class MockChatService {
  Future<ChatMessage> sendMessage(String message, String mode) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final rawQuestion = message.trim();
    if (rawQuestion.isEmpty) {
      return ChatMessage(
        text: 'Please ask me a specific concept or question to research.',
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
      );
    }

    final normalized = rawQuestion.toLowerCase();
    final concept = _extractConcept(rawQuestion);
    final answerType = _detectIntent(normalized);
    final facts = _retrieveRelevantFacts(concept);
    final keyPoints = _buildKeyPoints(concept, answerType);
    final sources = _buildSourcesForConcept(concept);
    final answer = _synthesizeAnswer(concept, answerType, facts);

    return ChatMessage(
      text: answer,
      sender: MessageSender.bot,
      timestamp: DateTime.now(),
      suggestions: [
        'Explain it simply',
        'Give me an example',
        'What are the limitations?',
      ],
      keyPoints: keyPoints,
      sources: sources,
    );
  }

  String _extractConcept(String rawQuestion) {
    var text = rawQuestion.trim();
    final prefixes = [
      'what is ',
      'what are ',
      'explain ',
      'describe ',
      'tell me about ',
      'how does ',
      'how do ',
      'how is ',
      'why does ',
      'what happened in ',
      'what is the difference between ',
      'difference between ',
      'give me an example of ',
      'give me a real-world example of ',
    ];

    for (final prefix in prefixes) {
      if (text.toLowerCase().startsWith(prefix)) {
        text = text.substring(prefix.length);
        break;
      }
    }

    text = text.replaceAll(RegExp(r'[?!.]+$'), '').trim();
    if (text.isEmpty) return 'general concept';
    return text;
  }

  String _detectIntent(String normalized) {
    if (normalized.contains('difference between') ||
        normalized.contains('vs ') ||
        normalized.contains('versus')) {
      return 'comparison';
    }
    if (normalized.contains('how does') ||
        normalized.contains('how do') ||
        normalized.contains('how it works') ||
        normalized.contains('works')) {
      return 'mechanism';
    }
    if (normalized.contains('example') ||
        normalized.contains('give me') ||
        normalized.contains('real-world')) {
      return 'example';
    }
    if (normalized.contains('advantage') ||
        normalized.contains('benefit') ||
        normalized.contains('pros')) {
      return 'advantages';
    }
    if (normalized.contains('disadvantage') ||
        normalized.contains('limitation') ||
        normalized.contains('cons')) {
      return 'limitations';
    }
    if (normalized.contains('latest') ||
        normalized.contains('newest') ||
        normalized.contains('recent')) {
      return 'latest';
    }
    return 'explanation';
  }

  List<_RetrievedFact> _retrieveRelevantFacts(String concept) {
    final lower = concept.toLowerCase();

    if (lower.contains('quantum computing')) {
      return const [
        _RetrievedFact(
          fact:
              'Quantum computing uses qubits, which can exist in superposition and be entangled, allowing certain calculations to be approached differently from classical computing.',
          provider: 'IBM Research',
          url: 'https://www.ibm.com/quantum',
        ),
        _RetrievedFact(
          fact:
              'Quantum computers are especially promising for simulation, optimization, and some cryptography-related problems, although they are not faster for every task.',
          provider: 'Wikipedia',
          url: 'https://en.wikipedia.org/wiki/Quantum_computing',
        ),
      ];
    }

    if (lower.contains('blockchain')) {
      return const [
        _RetrievedFact(
          fact:
              'Blockchain is a distributed digital ledger that records transactions across a network of computers instead of a single central database.',
          provider: 'IBM',
          url: 'https://www.ibm.com/topics/blockchain',
        ),
        _RetrievedFact(
          fact:
              'Transactions are grouped into blocks and linked together using cryptographic methods to help protect the integrity of the record.',
          provider: 'Wikipedia',
          url: 'https://en.wikipedia.org/wiki/Blockchain',
        ),
      ];
    }

    if (lower.contains('dns')) {
      return const [
        _RetrievedFact(
          fact:
              'DNS translates human-readable domain names like example.com into IP addresses that computers can use to locate services on the internet.',
          provider: 'Cloudflare',
          url: 'https://www.cloudflare.com/learning/dns/what-is-dns/',
        ),
        _RetrievedFact(
          fact:
              'The lookup process uses resolvers and authoritative name servers to determine which IP address belongs to a requested domain.',
          provider: 'Wikipedia',
          url: 'https://en.wikipedia.org/wiki/Domain_Name_System',
        ),
      ];
    }

    if (lower.contains('machine learning')) {
      return const [
        _RetrievedFact(
          fact:
              'Machine learning is a method of building systems that learn patterns from data and use those patterns to make predictions or decisions.',
          provider: 'IBM',
          url: 'https://www.ibm.com/topics/machine-learning',
        ),
        _RetrievedFact(
          fact:
              'Models update their internal parameters during training so they can generalize from examples to new inputs.',
          provider: 'Wikipedia',
          url: 'https://en.wikipedia.org/wiki/Machine_learning',
        ),
      ];
    }

    if (lower.contains('crispr')) {
      return const [
        _RetrievedFact(
          fact:
              'CRISPR is a gene-editing technology that lets scientists make targeted changes to DNA sequences in cells.',
          provider: 'Broad Institute',
          url:
              'https://www.broadinstitute.org/what-broad/areas-focus/project-areas/crispr',
        ),
        _RetrievedFact(
          fact:
              'The system uses a guide RNA to direct an enzyme like Cas9 to a matching genetic sequence so a targeted edit can be made.',
          provider: 'Wikipedia',
          url: 'https://en.wikipedia.org/wiki/CRISPR',
        ),
      ];
    }

    if (lower.contains('tcp') && lower.contains('udp')) {
      return const [
        _RetrievedFact(
          fact:
              'TCP is reliable and ordered, which makes it useful when correctness matters more than speed.',
          provider: 'Cloudflare',
          url: 'https://www.cloudflare.com/learning/ddos/glossary/tcp-vs-udp/',
        ),
        _RetrievedFact(
          fact:
              'UDP is lighter and faster, which makes it suitable for real-time traffic where low latency is more important than guaranteed delivery.',
          provider: 'Wikipedia',
          url: 'https://en.wikipedia.org/wiki/User_Datagram_Protocol',
        ),
      ];
    }

    if (lower.contains('cloud computing')) {
      return const [
        _RetrievedFact(
          fact:
              'Cloud computing delivers computing resources such as storage and processing power over the internet on demand.',
          provider: 'Microsoft Azure',
          url:
              'https://azure.microsoft.com/en-us/resources/cloud-computing-dictionary/what-is-cloud-computing',
        ),
        _RetrievedFact(
          fact:
              'Organizations can scale resources up or down quickly without buying and maintaining all the hardware themselves.',
          provider: 'AWS',
          url: 'https://aws.amazon.com/what-is-cloud-computing/',
        ),
      ];
    }

    if (lower.contains('electric vehicle') ||
        lower.contains('electric vehicles')) {
      return const [
        _RetrievedFact(
          fact:
              'Electric vehicles use rechargeable batteries and electric motors instead of internal combustion engines.',
          provider: 'U.S. Department of Energy',
          url: 'https://afdc.energy.gov/vehicles/electric_basics.html',
        ),
        _RetrievedFact(
          fact:
              'EVs can reduce tailpipe emissions and operating costs, but charging infrastructure and battery range remain important trade-offs.',
          provider: 'Wikipedia',
          url: 'https://en.wikipedia.org/wiki/Electric_vehicle',
        ),
      ];
    }

    return const [
      _RetrievedFact(
        fact:
            'The concept is best understood by combining its definition, main components, and practical applications into a clear summary.',
        provider: 'StudyMate',
        url: 'https://example.com',
      ),
    ];
  }

  String _synthesizeAnswer(
    String concept,
    String answerType,
    List<_RetrievedFact> facts,
  ) {
    final lower = concept.toLowerCase();

    if (lower.contains('quantum computing')) {
      return 'Quantum computing is a type of computing that uses the principles of quantum mechanics to process information. Classical computers use bits that are either 0 or 1, while quantum computers use qubits, which can exist in superposition and become linked through entanglement. This allows certain problems, especially in simulation, optimization, and some cryptography-related tasks, to be approached in a different way from classical computing.';
    }

    if (lower.contains('blockchain')) {
      return 'Blockchain is a distributed digital ledger used to record transactions across a network of computers. Transactions are grouped into blocks and linked together using cryptographic techniques, which helps protect the integrity of the record and reduce dependence on a single central authority. In simple terms, blockchain is a shared record book that many participants can validate and maintain together.';
    }

    if (lower.contains('dns')) {
      return 'DNS, or the Domain Name System, is the internet system that translates human-readable names like example.com into the IP addresses computers use to reach services online. When you type a website into a browser, resolvers and name servers work together to find the match. This makes the internet easier to use because people do not have to memorize long numeric addresses.';
    }

    if (lower.contains('machine learning')) {
      return 'Machine learning is a way of building systems that learn patterns from data rather than following only fixed rules. A model is trained on examples so it can detect structure, make predictions, and classify new inputs. In practice, machine learning is used in recommendation systems, image recognition, fraud detection, and many other tasks that require pattern recognition from large sets of data.';
    }

    if (lower.contains('crispr')) {
      return 'CRISPR is a gene-editing technology that lets scientists make targeted changes to DNA. It uses a guide RNA to direct an enzyme such as Cas9 to a matching DNA sequence, where the gene can be cut, repaired, or modified. This makes CRISPR a powerful tool for precise genetic research and engineering.';
    }

    if (lower.contains('tcp') && lower.contains('udp')) {
      return 'TCP and UDP are both transport-layer protocols, but they optimize for different priorities. TCP is reliable and ordered, which makes it useful when data accuracy matters, while UDP is lighter and faster, which makes it better for real-time traffic where low latency matters more than guaranteed delivery. In short, TCP favors reliability and UDP favors speed.';
    }

    if (lower.contains('cloud computing')) {
      return 'Cloud computing is the delivery of computing resources over the internet on demand. Instead of buying and maintaining physical servers, organizations can rent storage, processing power, and managed services from a cloud provider. This gives them more flexibility, faster scaling, and lower upfront infrastructure costs.';
    }

    if (lower.contains('electric vehicle') ||
        lower.contains('electric vehicles')) {
      return 'Electric vehicles are vehicles powered by rechargeable batteries and electric motors instead of internal combustion engines. They can reduce tailpipe emissions and operating costs, but they still depend on battery performance, charging infrastructure, and the energy used to generate electricity. In other words, EVs offer environmental and efficiency advantages, while also introducing trade-offs around charging and range.';
    }

    if (answerType == 'mechanism') {
      return 'The core mechanism behind this concept is that it takes an input, applies a structured process, and then produces an output based on rules, patterns, or data. The important idea is how the different parts interact to create the final behavior or result.';
    }

    if (answerType == 'comparison') {
      return 'The key idea is to compare the core differences in behavior, trade-offs, and ideal use cases. The explanation focuses on what each option is designed to do best, so the learner can understand when one approach is preferable over another.';
    }

    if (answerType == 'limitations') {
      return 'A practical limitation of this concept is that it depends heavily on the quality, completeness, and relevance of the data or assumptions it uses. Real systems also involve trade-offs such as cost, complexity, uncertainty, and constraints, so the best answer should present both benefits and drawbacks.';
    }

    if (facts.isNotEmpty) {
      final uniqueFacts = facts.map((fact) => fact.fact).toSet().toList();
      if (uniqueFacts.isNotEmpty) {
        return uniqueFacts.first;
      }
    }

    return 'This concept is best understood by combining its definition, the problem it solves, and its main components. The explanation should stay concise while making the idea easy to understand and grounded in reliable supporting sources.';
  }

  List<String> _buildKeyPoints(String concept, String answerType) {
    final lower = concept.toLowerCase();

    if (lower.contains('quantum computing')) {
      return [
        'Uses qubits instead of classical binary bits.',
        'Relies on quantum phenomena such as superposition and entanglement.',
        'Can be valuable for optimization, simulation, and some cryptography problems.',
        'Current hardware is still limited by noise, scale, and error rates.',
      ];
    }

    if (lower.contains('blockchain')) {
      return [
        'Stores transactions in a distributed ledger.',
        'Groups records into blocks linked by cryptography.',
        'Reduces dependence on a single central authority.',
        'Improves transparency and tamper resistance.',
      ];
    }

    if (lower.contains('dns')) {
      return [
        'DNS maps names to IP addresses.',
        'Resolvers and name servers help locate the correct address.',
        'This system keeps the internet human-friendly and easier to use.',
      ];
    }

    if (lower.contains('machine learning')) {
      return [
        'Machine learning looks for patterns in data.',
        'Models learn by adjusting parameters during training.',
        'It powers prediction, classification, and recommendation systems.',
      ];
    }

    if (lower.contains('crispr')) {
      return [
        'CRISPR is a targeted DNA-editing technology.',
        'It uses guide RNA to find a matching gene sequence.',
        'It can repair, disable, or replace genes in a precise way.',
      ];
    }

    if (lower.contains('tcp') && lower.contains('udp')) {
      return [
        'TCP emphasizes reliability and ordered delivery.',
        'UDP emphasizes speed and lower latency.',
        'The better choice depends on whether correctness or responsiveness matters more.',
      ];
    }

    if (lower.contains('cloud computing')) {
      return [
        'Cloud computing delivers resources on demand over the internet.',
        'It reduces upfront hardware and infrastructure costs.',
        'It supports rapid scaling and managed service delivery.',
      ];
    }

    if (lower.contains('electric vehicle') ||
        lower.contains('electric vehicles')) {
      return [
        'Electric vehicles use rechargeable batteries and electric motors.',
        'They can cut tailpipe emissions and reduce fuel costs.',
        'Charging access, range, and battery manufacturing remain key trade-offs.',
      ];
    }

    if (answerType == 'comparison') {
      return [
        'Compares core differences in behavior and trade-offs.',
        'Highlights where each option is strongest.',
        'Connects decisions to actual use cases.',
      ];
    }

    return [
      'Explains the core definition clearly.',
      'Presents the main idea in student-friendly language.',
      'Uses supporting sources to keep the answer grounded and accurate.',
    ];
  }

  List<EducationalSource> _buildSourcesForConcept(String concept) {
    final normalized = concept.toLowerCase();

    if (normalized.contains('quantum computing')) {
      return [
        EducationalSource(
          title: 'Quantum computing',
          provider: 'IBM Research',
          url: 'https://www.ibm.com/quantum',
          summary:
              'Official IBM overview of quantum computing principles and applications.',
          relevanceScore: 0.98,
          type: 'official',
        ),
        EducationalSource(
          title: 'Quantum computing',
          provider: 'Wikipedia',
          url: 'https://en.wikipedia.org/wiki/Quantum_computing',
          summary:
              'Reference overview of qubits, superposition, and entanglement.',
          relevanceScore: 0.94,
          type: 'reference',
        ),
      ];
    }

    if (normalized.contains('blockchain')) {
      return [
        EducationalSource(
          title: 'What is blockchain?',
          provider: 'IBM',
          url: 'https://www.ibm.com/topics/blockchain',
          summary:
              'Clear explanation of blockchain trust, records, and structure.',
          relevanceScore: 0.98,
          type: 'official',
        ),
        EducationalSource(
          title: 'Blockchain',
          provider: 'Wikipedia',
          url: 'https://en.wikipedia.org/wiki/Blockchain',
          summary: 'Reference overview of distributed ledgers and blocks.',
          relevanceScore: 0.93,
          type: 'reference',
        ),
      ];
    }

    if (normalized.contains('dns')) {
      return [
        EducationalSource(
          title: 'What is DNS?',
          provider: 'Cloudflare',
          url: 'https://www.cloudflare.com/learning/dns/what-is-dns/',
          summary: 'Practical explanation of how DNS resolves domain names.',
          relevanceScore: 0.97,
          type: 'educational',
        ),
        EducationalSource(
          title: 'Domain Name System',
          provider: 'Wikipedia',
          url: 'https://en.wikipedia.org/wiki/Domain_Name_System',
          summary: 'Reference overview of DNS hierarchy and lookup behavior.',
          relevanceScore: 0.91,
          type: 'reference',
        ),
      ];
    }

    if (normalized.contains('machine learning')) {
      return [
        EducationalSource(
          title: 'Machine learning',
          provider: 'IBM',
          url: 'https://www.ibm.com/topics/machine-learning',
          summary: 'Accessible explanation of core ML ideas and patterns.',
          relevanceScore: 0.98,
          type: 'official',
        ),
        EducationalSource(
          title: 'Machine learning',
          provider: 'Wikipedia',
          url: 'https://en.wikipedia.org/wiki/Machine_learning',
          summary:
              'Reference explanation of learning from data and model training.',
          relevanceScore: 0.93,
          type: 'reference',
        ),
      ];
    }

    if (normalized.contains('crispr')) {
      return [
        EducationalSource(
          title: 'CRISPR',
          provider: 'Broad Institute',
          url:
              'https://www.broadinstitute.org/what-broad/areas-focus/project-areas/crispr',
          summary: 'Reliable explanation of CRISPR and gene editing.',
          relevanceScore: 0.96,
          type: 'official',
        ),
        EducationalSource(
          title: 'CRISPR',
          provider: 'Wikipedia',
          url: 'https://en.wikipedia.org/wiki/CRISPR',
          summary: 'Reference summary of CRISPR systems and genome editing.',
          relevanceScore: 0.92,
          type: 'reference',
        ),
      ];
    }

    if (normalized.contains('tcp') && normalized.contains('udp')) {
      return [
        EducationalSource(
          title: 'TCP vs UDP',
          provider: 'Cloudflare Learning',
          url: 'https://www.cloudflare.com/learning/ddos/glossary/tcp-vs-udp/',
          summary:
              'Practical comparison of reliability and latency trade-offs.',
          relevanceScore: 0.97,
          type: 'educational',
        ),
        EducationalSource(
          title: 'User Datagram Protocol',
          provider: 'Wikipedia',
          url: 'https://en.wikipedia.org/wiki/User_Datagram_Protocol',
          summary: 'Reference explanation of UDP behavior.',
          relevanceScore: 0.88,
          type: 'reference',
        ),
      ];
    }

    if (normalized.contains('cloud computing')) {
      return [
        EducationalSource(
          title: 'What is cloud computing?',
          provider: 'Microsoft Azure',
          url:
              'https://azure.microsoft.com/en-us/resources/cloud-computing-dictionary/what-is-cloud-computing',
          summary:
              'Understanding cloud resources, scaling, and service models.',
          relevanceScore: 0.96,
          type: 'official',
        ),
        EducationalSource(
          title: 'Cloud computing',
          provider: 'AWS',
          url: 'https://aws.amazon.com/what-is-cloud-computing/',
          summary: 'Practical overview of on-demand services and benefits.',
          relevanceScore: 0.95,
          type: 'official',
        ),
      ];
    }

    if (normalized.contains('electric vehicle') ||
        normalized.contains('electric vehicles')) {
      return [
        EducationalSource(
          title: 'Electric Vehicles',
          provider: 'U.S. Department of Energy',
          url: 'https://afdc.energy.gov/vehicles/electric_basics.html',
          summary:
              'Practical overview of EV technology and emissions trade-offs.',
          relevanceScore: 0.96,
          type: 'official',
        ),
        EducationalSource(
          title: 'Electric vehicle',
          provider: 'Wikipedia',
          url: 'https://en.wikipedia.org/wiki/Electric_vehicle',
          summary: 'Reference summary of EV design and impact.',
          relevanceScore: 0.92,
          type: 'reference',
        ),
      ];
    }

    return [
      EducationalSource(
        title: concept,
        provider: 'Wikipedia',
        url: 'https://en.wikipedia.org/wiki/${concept.replaceAll(' ', '_')}',
        summary:
            'General reference for the requested concept and its foundation.',
        relevanceScore: 0.9,
        type: 'reference',
      ),
    ];
  }
}
