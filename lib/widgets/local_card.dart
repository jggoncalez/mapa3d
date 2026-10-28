import 'package:flutter/material.dart';

import '../models/local.dart';
import '../utils/formatadores.dart';

/// Item da lista de resultados (imagem, nome, categoria, distância e avaliação).
class LocalCard extends StatelessWidget {
  final Local local;
  final VoidCallback onTap;
  final VoidCallback? onEditar;
  final VoidCallback? onExcluir;

  const LocalCard({
    super.key,
    required this.local,
    required this.onTap,
    this.onEditar,
    this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final temMenu = onEditar != null || onExcluir != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: tema.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.image_outlined, color: Colors.grey.shade600, size: 34),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      local.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(local.categoria, style: tema.textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 14),
                        const SizedBox(width: 4),
                        Text(formatarKm(local.distancia), style: tema.textTheme.bodySmall),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          formatarNota(local.avaliacao),
                          style: tema.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (local.favorito)
                const Icon(Icons.favorite, color: Colors.red, size: 18),
              if (temMenu)
                PopupMenuButton<String>(
                  tooltip: 'Ações',
                  onSelected: (valor) {
                    if (valor == 'editar') onEditar?.call();
                    if (valor == 'excluir') onExcluir?.call();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem<String>(value: 'editar', child: Text('Editar')),
                    PopupMenuItem<String>(value: 'excluir', child: Text('Excluir')),
                  ],
                ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
