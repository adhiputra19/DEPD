part of 'widgets.dart';

class BottomSheetCostDetails extends StatelessWidget {
  final Costs cost;

  const BottomSheetCostDetails({super.key, required this.cost});

  String _rupiahMoneyFormatter(num? value) {
    if (value == null) return "Rp0,00";
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }


  String _formatEtd(String? etd) {
    if (etd == null || etd.isEmpty) return '-';

    String value = etd
        .toLowerCase()
        .replaceAll("hari", "")      
        .replaceAll("day", "")       
        .replaceAll("days", "")      
        .replaceAll(" ", "");        

    return '$value hari';
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
          const Text(
            ' : ',
            style: TextStyle(fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courierName = cost.name ?? '-';
    final code = (cost.code ?? '').toUpperCase();
    final service = cost.service ?? '-';
    final desc = cost.description ?? '-';
    final biaya = _rupiahMoneyFormatter(cost.cost);
    final etd = _formatEtd(cost.etd);

    String headerTitle;
      if (courierName.toUpperCase().contains('($code)')) {
        headerTitle = courierName;
      } else {
        headerTitle = '$courierName ($code)';
      }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // handle kecil di atas
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(999),
              ),
            ),

            // Header seperti contoh: icon + nama kurir + code di atas, close button di kanan
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue[50],
                  child: Icon(
                    Icons.local_shipping,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headerTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        service,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),

            const SizedBox(height: 4),
            _buildRow('Nama Kurir', courierName),
            _buildRow('Kode', code),
            _buildRow('Layanan', service),
            _buildRow('Deskripsi', desc),
            _buildRow('Biaya', biaya),
            _buildRow('Estimasi Pengiriman', etd),
          ],
        ),
      ),
    );
  }
}
