import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/package_item.dart';
import '../services/sirup_api_service.dart';
import '../widgets/package_card.dart';

class TenderScreen extends StatefulWidget {
  const TenderScreen({super.key});

  @override
  State<TenderScreen> createState() => _TenderScreenState();
}

class _TenderScreenState extends State<TenderScreen> {
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
      context.read<SirupApiService>().loadMorePackages();
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
                  hintText: 'Cari paket pengadaan...',
                  border: InputBorder.none,
                  filled: false,
                ),
                onSubmitted: (value) {
                  sirupService.searchPackages(value);
                },
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.notifications_rounded,
                      size: 18,
                      color: Colors.amber.shade700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tender Terbaru',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (sirupService.totalPackages > 0)
                        Text(
                          '${sirupService.totalPackages} paket',
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
                  sirupService.searchPackages('');
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => sirupService.fetchPackages(refresh: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => sirupService.fetchPackages(refresh: true),
        child: _buildBody(sirupService, theme),
      ),
    );
  }

  Widget _buildBody(SirupApiService service, ThemeData theme) {
    if (service.isLoadingPackages && service.packages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (service.error != null && service.packages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data',
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
                onPressed: () => service.fetchPackages(refresh: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (service.packages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Tidak ada data paket',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: service.packages.length + 1,
      itemBuilder: (context, index) {
        if (index == service.packages.length) {
          if (service.isLoadingPackages) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return const SizedBox.shrink();
        }

        final pkg = service.packages[index];
        return PackageCard(
          item: pkg,
          onTap: () => _showPackageDetail(context, pkg),
        );
      },
    );
  }

  void _showPackageDetail(BuildContext context, PackageItem item) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollController) => Padding(
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

              // Package name
              Text(
                item.packageName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Satker
              _detailRow(Icons.business, 'Satuan Kerja', item.satker),
              const SizedBox(height: 12),

              // Budget
              _detailRow(
                Icons.monetization_on,
                'Anggaran',
                item.budgetFormatted,
              ),
              const SizedBox(height: 12),

              // Method & Type
              if (item.procurementMethod != null)
                _detailRow(
                  Icons.category,
                  'Metode',
                  item.procurementMethod!,
                ),
              if (item.procurementType != null) ...[
                const SizedBox(height: 12),
                _detailRow(
                  Icons.assignment,
                  'Jenis',
                  item.procurementType!,
                ),
              ],

              const SizedBox(height: 12),

              // Realisasi
              if (item.hasRealisasi) ...[
                _detailRow(
                  Icons.check_circle,
                  'Realisasi',
                  '${item.realisasiFormatted} (${item.realisasiPersen.toStringAsFixed(1)}%)',
                ),
              ] else ...[
                _detailRow(
                  Icons.pending,
                  'Realisasi',
                  'Belum realisasi',
                ),
              ],

              // Funding source
              if (item.fundingSource != null) ...[
                const SizedBox(height: 12),
                _detailRow(
                  Icons.account_balance,
                  'Sumber Dana',
                  item.fundingSource!,
                ),
              ],

              // UMKM
              if (item.isUmkm != null) ...[
                const SizedBox(height: 12),
                _detailRow(
                  Icons.store,
                  'UMKM',
                  item.isUmkm!,
                ),
              ],

              // Work description
              if (item.workDescription != null &&
                  item.workDescription!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Deskripsi Pekerjaan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.workDescription!,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
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
    );
  }
}
