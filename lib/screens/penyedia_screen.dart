import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/penyedia.dart';
import '../services/sirup_api_service.dart';
import '../widgets/penyedia_card.dart';

class PenyediaScreen extends StatefulWidget {
  const PenyediaScreen({super.key});

  @override
  State<PenyediaScreen> createState() => _PenyediaScreenState();
}

class _PenyediaScreenState extends State<PenyediaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SirupApiService>().loadMorePenyedia();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sirupService = context.watch<SirupApiService>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Cari penyedia...',
                  border: InputBorder.none,
                  filled: false,
                ),
                onSubmitted: (value) {
                  sirupService.searchPenyedia(value);
                },
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.business_rounded,
                      size: 18,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Data Penyedia',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (sirupService.totalPenyedia > 0)
                        Text(
                          '${sirupService.totalPenyedia} vendor',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  sirupService.searchPenyedia('');
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => sirupService.fetchPenyedia(refresh: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => sirupService.fetchPenyedia(refresh: true),
        child: _buildBody(sirupService, theme),
      ),
    );
  }

  Widget _buildBody(SirupApiService service, ThemeData theme) {
    if (service.isLoadingPenyedia && service.penyediaList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (service.error != null && service.penyediaList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data penyedia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                service.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500),
              ),
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: () => service.fetchPenyedia(refresh: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (service.penyediaList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Tidak ada data penyedia',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: service.penyediaList.length + 1,
      itemBuilder: (context, index) {
        if (index == service.penyediaList.length) {
          if (service.isLoadingPenyedia) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return const SizedBox.shrink();
        }

        final penyedia = service.penyediaList[index];
        return PenyediaCard(
          item: penyedia,
          onTap: () => _showPenyediaDetail(context, penyedia, service),
        );
      },
    );
  }

  void _showPenyediaDetail(
    BuildContext context,
    Penyedia item,
    SirupApiService service,
  ) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        expand: false,
        builder: (ctx, scrollController) => FutureBuilder<Penyedia?>(
          future: service.getPenyediaDetail(item.nama),
          builder: (ctx, snapshot) {
            final data = snapshot.data ?? item;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.teal.shade50,
                        child: Text(
                          item.initialLetters,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.nama,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            if (data.jenisUsaha != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                data.jenisUsaha!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (data.isVerified)
                        Icon(
                          Icons.verified,
                          size: 28,
                          color: Colors.green.shade600,
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),

                  // Details
                  if (data.npwp != null && data.npwp!.isNotEmpty)
                    _buildDetailTile(
                      Icons.badge_outlined,
                      'NPWP',
                      data.npwp!,
                    ),
                  if (data.telepon != null && data.telepon!.isNotEmpty)
                    _buildDetailTile(
                      Icons.phone_outlined,
                      'Telepon',
                      data.telepon!,
                    ),
                  if (data.email != null && data.email!.isNotEmpty)
                    _buildDetailTile(
                      Icons.email_outlined,
                      'Email',
                      data.email!,
                    ),
                  if (data.alamat != null && data.alamat!.isNotEmpty)
                    _buildDetailTile(
                      Icons.location_on_outlined,
                      'Alamat',
                      data.alamat!,
                    ),
                  if (data.tanggalDaftar != null &&
                      data.tanggalDaftar!.isNotEmpty)
                    _buildDetailTile(
                      Icons.calendar_today_outlined,
                      'Tanggal Daftar',
                      data.tanggalDaftar!,
                    ),
                  if (data.status != null && data.status!.isNotEmpty)
                    _buildDetailTile(
                      Icons.info_outline,
                      'Status',
                      data.status!,
                    ),

                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
