import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/football_provider.dart';
import '../../core/theme/theme_notifier.dart';

class FootballScreen extends StatefulWidget {
  @override
  State<FootballScreen> createState() => _FootballScreenState();
}

class _FootballScreenState extends State<FootballScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Perbaikan 1: Tunggu frame pertama selesai di-build sebelum memanggil provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FootballProvider>().fetchFootballs();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        context.read<FootballProvider>().fetchFootballs();
      }
    });
  }

  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date).toLocal();
      return DateFormat("dd MMM yyyy, HH:mm").format(parsed);
    } catch (e) {
      return date;
    }
  }

  void showGenerateDialog() {
    final leagueController = TextEditingController(); // Ubah ke league
    final totalController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Consumer<FootballProvider>(
          builder: (context, provider, _) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text("⚽ Generate Klub Bola"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: leagueController,
                    decoration: InputDecoration(
                      labelText: "Liga (Misal: Serie A)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: totalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Total",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: provider.isGenerating ? null : () => Navigator.pop(dialogContext),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: provider.isGenerating
                      ? null
                      : () async {
                    await provider.generate(
                      leagueController.text,
                      int.parse(totalController.text),
                    );
                    Navigator.pop(dialogContext);
                  },
                  child: provider.isGenerating
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                      SizedBox(width: 10),
                      Text("Generating..."),
                    ],
                  )
                      : Text("Generate"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FootballProvider>();
    final theme = context.watch<ThemeNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Info Klub Sepak Bola", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(icon: Icon(Icons.dark_mode), onPressed: theme.toggleTheme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showGenerateDialog,
        icon: Icon(Icons.sports_soccer),
        label: Text("Generate"),
        backgroundColor: Color(0xFF10B981), // Ganti warna hijau agar lebih "lapangan"
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(bottom: 120),
              itemCount: provider.footballs.length + 1,
              itemBuilder: (context, index) {
                if (index < provider.footballs.length) {
                  final item = provider.footballs[index];
                  final number = index + 1;

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    padding: EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF047857)]),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: Offset(0, 6))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("#$number", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8), // Beri sedikit jarak

                            // Perbaikan 2: Gunakan Expanded agar tidak overflow
                            Expanded(
                              child: Text(
                                formatDate(item.createdAt),
                                style: TextStyle(color: Colors.white60, fontSize: 11),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis, // Potong dengan "..." jika kepanjangan
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          item.name, // Menampilkan Nama Klub
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            "Liga: ${item.league}", // Menampilkan Liga
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return provider.isLoading
                      ? Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [CircularProgressIndicator(), SizedBox(height: 8), Text("Loading...")],
                    ),
                  )
                      : SizedBox();
                }
              },
            ),
          ),
          if (provider.isGenerating)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}