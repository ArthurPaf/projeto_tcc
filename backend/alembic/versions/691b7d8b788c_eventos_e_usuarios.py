"""eventos e usuarios

Revision ID: 691b7d8b788c
Revises:
Create Date: 2026-09-17 19:35:45.914543

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '691b7d8b788c'
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table(
        'usuarios',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('nome', sa.String(80), nullable=False),
        sa.Column('email', sa.String(120), nullable=False),
        sa.Column('senha_hash', sa.String(100), nullable=False),
    )
    op.create_index('ix_usuarios_id', 'usuarios', ['id'])
    op.create_index('ix_usuarios_email', 'usuarios', ['email'], unique=True)
    # dono_id entra na migração seguinte, como na sequência das aulas.
    op.create_table(
        'evento',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('nome', sa.String(120), nullable=False),
        sa.Column('data_inicio', sa.String(20), nullable=False),
        sa.Column('data_fim', sa.String(20), nullable=False),
        sa.Column('local', sa.String(50), nullable=False),
    )
    op.create_index('ix_evento_id', 'evento', ['id'])


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index('ix_evento_id', table_name='evento')
    op.drop_table('evento')
    op.drop_index('ix_usuarios_email', table_name='usuarios')
    op.drop_index('ix_usuarios_id', table_name='usuarios')
    op.drop_table('usuarios')
